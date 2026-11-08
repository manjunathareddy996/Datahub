"""Unit tests for dvgen.scaffold (Requirements 2.1-2.7).

Each test builds a fake Template_Project in ``tmp_path``: the real
template's ``dbt_project.yml``, ``packages.yml`` and ``profiles.yml`` text
(read only) plus small fake macros and a small fake ``dbt_packages/`` tree.
"""
from __future__ import annotations

import hashlib
from pathlib import Path
from types import SimpleNamespace

import pytest
import yaml

from dvgen.emit import WriteGuard
from dvgen.scaffold import (
    EXPECTED_DBT_PROJECT,
    LAYER_MATERIALIZATION,
    MACROS,
    MODEL_FOLDERS,
    SCHEMA,
    TEMPLATE_NAME,
    TEMPLATE_PROFILE,
    CopyMismatch,
    ConfigError,
    TemplateMismatch,
    check_dbt_project_layers,
    find_secret_keys,
    render_profiles,
    scaffold,
    tree_digests,
)

REAL_TEMPLATE = Path(__file__).resolve().parents[3] / "opus_partner_dv_dbt"
CONFIG_FILES = ("dbt_project.yml", "packages.yml", "profiles.yml")

PROJECT = "opus_health_dv_dbt"
PROFILE = "opus_health_dbt"
VARS = {"health_raw_database": "RAW_DB", "health_raw_schema": "RAW_SCHEMA"}

FAKE_PACKAGES = {
    "dbt_utils/dbt_project.yml": b"name: 'dbt_utils'\n",
    "dbt_utils/macros/a.sql": b"{% macro a() %}1{% endmacro %}\r\n",
    "automate_dv/dbt_project.yml": b"name: 'automate_dv'\n",
    "automate_dv/macros/tables/hub.sql": b"-- hub \xc3\xa9\n",
}


def _sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _real_text(name: str) -> str:
    return (REAL_TEMPLATE / name).read_bytes().decode("utf-8")


@pytest.fixture
def template(tmp_path) -> Path:
    tpl = tmp_path / "template"
    (tpl / "macros").mkdir(parents=True)
    for name in CONFIG_FILES:
        (tpl / name).write_bytes((REAL_TEMPLATE / name).read_bytes())
    for name in MACROS:
        # CRLF and non-ASCII bytes check that the copy is byte-for-byte.
        (tpl / "macros" / f"{name}.sql").write_bytes(
            f"{{% macro {name}() %}}\r\n-- é {name}\r\n{{% endmacro %}}".encode()
        )
    for rel, data in FAKE_PACKAGES.items():
        path = tpl / "dbt_packages" / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
    return tpl


@pytest.fixture
def project(tmp_path) -> Path:
    root = tmp_path / "proj"
    root.mkdir()
    return root


def _cfg(template: Path, **over) -> SimpleNamespace:
    values = dict(PROJECT=PROJECT, PROFILE=PROFILE, VARS=dict(VARS),
                  TEMPLATE_PROJECT=template)
    values.update(over)
    return SimpleNamespace(**values)


def _replaced(template_text: str, cfg) -> list[str]:
    """Template lines with only the three replaced items changed."""
    out: list[str] = []
    in_vars = False
    for line in template_text.splitlines():
        if line == f"name: '{TEMPLATE_NAME}'":
            out.append(f"name: '{cfg.PROJECT}'")
        elif line == f"profile: '{TEMPLATE_PROFILE}'":
            out.append(f"profile: '{cfg.PROFILE}'")
        elif line == f"  {TEMPLATE_NAME}:":
            out.append(f"  {cfg.PROJECT}:")
        elif line == "vars:":
            in_vars = True
            out.append(line)
            out.extend(f"  {k}: {v}" for k, v in cfg.VARS.items())
        elif in_vars and line.startswith("  "):
            continue
        else:
            in_vars = False
            out.append(line)
    return out


# --------------------------------------------------------------------------
# happy path
# --------------------------------------------------------------------------

def test_dbt_project_differs_only_in_replaced_items(template, project):
    cfg = _cfg(template)
    scaffold(cfg, project)
    out = (project / "dbt_project.yml").read_text(encoding="utf-8")
    tpl_text = _real_text("dbt_project.yml")
    assert out.splitlines() == _replaced(tpl_text, cfg)
    assert TEMPLATE_NAME not in out
    assert TEMPLATE_PROFILE not in out
    doc = yaml.safe_load(out)
    assert doc["name"] == PROJECT
    assert doc["profile"] == PROFILE
    assert doc["vars"] == VARS
    assert list(doc["models"]) == [PROJECT]


def test_every_layer_has_schema_and_materialization(template, project):
    scaffold(_cfg(template), project)
    doc = yaml.safe_load((project / "dbt_project.yml").read_text("utf-8"))
    root = doc["models"][PROJECT]
    assert root["staging"]["+schema"] == SCHEMA
    assert root["raw_vault"]["standard"]["+schema"] == SCHEMA
    assert root["raw_vault"]["augmented"]["+schema"] == SCHEMA
    for path, mat in LAYER_MATERIALIZATION.items():
        node = root
        for part in path:
            node = node[part]
        assert node["+materialized"] == mat, path
    expected = {
        ("staging",): "view",
        ("raw_vault", "standard", "stitched"): "view",
        ("raw_vault", "standard", "staging"): "view",
        ("raw_vault", "standard", "hubs"): "incremental",
        ("raw_vault", "standard", "links"): "incremental",
        ("raw_vault", "standard", "satellites"): "incremental",
        ("raw_vault", "standard", "references"): "view",
        ("raw_vault", "augmented", "staging"): "view",
        ("raw_vault", "augmented", "satellites"): "incremental",
    }
    assert LAYER_MATERIALIZATION == expected


def test_macro_and_package_digests_equal_template(template, project):
    result = scaffold(_cfg(template), project)
    tpl_macros = {f"{m}.sql": _sha((template / "macros" / f"{m}.sql").read_bytes())
                  for m in MACROS}
    assert tree_digests(project / "macros") == tpl_macros
    assert result.macro_digests == tpl_macros
    tpl_pkgs = tree_digests(template / "dbt_packages")
    assert tpl_pkgs == {k: _sha(v) for k, v in FAKE_PACKAGES.items()}
    assert tree_digests(project / "dbt_packages") == tpl_pkgs
    assert result.package_digests == tpl_pkgs


def test_folder_layout_exists(template, project):
    result = scaffold(_cfg(template), project)
    assert result.folders == list(MODEL_FOLDERS)
    for rel in MODEL_FOLDERS:
        assert (project / rel).is_dir(), rel


def test_packages_verbatim_and_profiles_have_no_secrets(template, project):
    scaffold(_cfg(template), project)
    assert (project / "packages.yml").read_bytes().decode("utf-8") == \
        _real_text("packages.yml").replace("\r\n", "\n")
    profiles = (project / "profiles.yml").read_text(encoding="utf-8")
    assert find_secret_keys(profiles) == []
    doc = yaml.safe_load(profiles)
    assert list(doc) == [PROFILE]
    keys: set[str] = set()

    def walk(node):
        if isinstance(node, dict):
            for k, v in node.items():
                keys.add(str(k).lower())
                walk(v)

    walk(doc)
    for bad in ("password", "token", "private_key", "private_key_path",
                "passphrase"):
        assert bad not in keys


def test_template_is_not_modified(template, project):
    before = tree_digests(template)
    scaffold(_cfg(template), project)
    assert tree_digests(template) == before


# --------------------------------------------------------------------------
# negative cases
# --------------------------------------------------------------------------

def test_mismatched_template_line_stops_with_no_output(template, project):
    path = template / "dbt_project.yml"
    text = path.read_bytes().decode("utf-8")
    path.write_bytes(text.replace("+materialized: view", "+materialized: table",
                                  1).encode("utf-8"))
    with pytest.raises(TemplateMismatch) as exc:
        scaffold(_cfg(template), project)
    err = exc.value
    assert err.file == "dbt_project.yml"
    expected_line = "      +materialized: view"
    assert expected_line in EXPECTED_DBT_PROJECT
    assert err.expected == repr(expected_line)
    assert err.actual == "      +materialized: table"
    assert err.line_no == text.splitlines().index(expected_line) + 1
    assert list(project.iterdir()) == []


def test_extra_template_line_is_reported(template, project):
    path = template / "dbt_project.yml"
    text = path.read_bytes().decode("utf-8").rstrip() + "\nextra: 1\n"
    path.write_bytes(text.encode("utf-8"))
    with pytest.raises(TemplateMismatch) as exc:
        scaffold(_cfg(template), project)
    assert exc.value.actual == "extra: 1"
    assert exc.value.expected == "<end of file>"


def test_secret_key_in_profiles_is_refused(template, project):
    path = template / "profiles.yml"
    text = path.read_bytes().decode("utf-8").replace(
        '      user: "_"', '      user: "_"\n      password: "hunter2"', 1)
    path.write_bytes(text.encode("utf-8"))
    with pytest.raises(TemplateMismatch) as exc:
        scaffold(_cfg(template), project)
    assert exc.value.file == "profiles.yml"
    assert exc.value.actual == "password"
    assert list(project.iterdir()) == []


@pytest.mark.parametrize("key", ["token", "private_key_path",
                                 "private_key_passphrase", "client_secret"])
def test_find_secret_keys_flags_secret_fields(key):
    text = f"p:\n  outputs:\n    dev:\n      {key}: x\n"
    assert find_secret_keys(text) == [(4, key)]
    with pytest.raises(TemplateMismatch):
        render_profiles(f"{TEMPLATE_PROFILE}:\n  outputs:\n    dev:\n      {key}: x\n",
                        _cfg(Path(".")))


def test_extra_file_in_package_copy_is_reported(template, project):
    stray = project / "dbt_packages" / "dbt_utils" / "stray.sql"
    stray.parent.mkdir(parents=True)
    stray.write_bytes(b"select 1\n")
    with pytest.raises(CopyMismatch) as exc:
        scaffold(_cfg(template), project)
    assert exc.value.what == "dbt_packages"
    assert exc.value.differences == ["dbt_utils/stray.sql: not in template"]


class _CorruptingGuard(WriteGuard):
    """Writes macros with one byte changed, to prove the digest check runs."""

    def write_bytes(self, rel_path, data):
        if str(rel_path) == "macros/hash.sql":
            data = data + b" "
        return super().write_bytes(rel_path, data)


def test_changed_macro_copy_is_reported(template, project):
    with pytest.raises(CopyMismatch) as exc:
        scaffold(_cfg(template), project, guard=_CorruptingGuard(project))
    assert exc.value.what == "macros"
    assert len(exc.value.differences) == 1
    assert exc.value.differences[0].startswith("hash.sql: sha256 ")


def test_missing_macro_in_template_is_reported(template, project):
    (template / "macros" / "watermark.sql").unlink()
    with pytest.raises(TemplateMismatch) as exc:
        scaffold(_cfg(template), project)
    assert exc.value.file == "macros/watermark.sql"


def test_layer_check_rejects_wrong_materialization(template):
    from dvgen.scaffold import render_dbt_project

    text = render_dbt_project(_real_text("dbt_project.yml"), _cfg(template))
    bad = text.replace("        hubs:\n          +materialized: incremental",
                       "        hubs:\n          +materialized: view")
    assert bad != text
    with pytest.raises(TemplateMismatch):
        check_dbt_project_layers(bad, PROJECT)


@pytest.mark.parametrize("over", [
    {"PROJECT": "Bad-Name"},
    {"PROFILE": ""},
    {"VARS": {}},
    {"VARS": {"k": "has space"}},
])
def test_invalid_config_is_refused(template, project, over):
    with pytest.raises(ConfigError):
        scaffold(_cfg(template, **over), project)
