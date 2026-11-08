"""Scaffold a Health_Project's dbt configuration from the Template_Project.

``scaffold(cfg, project_root)``:

1. Copies the 8 macros and the ``dbt_packages/`` tree byte-for-byte from
   the Template_Project, then compares sha256 trees of source and copy
   (Requirements 2.3, 2.4).
2. Renders ``dbt_project.yml`` from the template by replacing the project
   name (``name:`` and the top-level ``models:`` key), the profile name and
   the ``vars:`` block. Every other line is asserted unchanged
   (Requirements 2.1, 2.2, 2.6).
3. Renders ``packages.yml`` verbatim and ``profiles.yml`` with only the top
   key renamed. ``profiles.yml`` must carry no password, token or key field
   (Requirements 2.1, 2.7).
4. Creates the model folder layout (Requirement 2.5).

The Template_Project is read only. Every write goes through ``WriteGuard``.
When a template file does not have the expected structure the scaffold
stops with ``TemplateMismatch`` showing the first differing line.

This module is project-agnostic. The caller passes a config object with
``PROJECT``, ``PROFILE``, ``VARS`` and ``TEMPLATE_PROJECT`` (a path,
relative paths resolved against the project root).
"""
from __future__ import annotations

import hashlib
import os
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Mapping, Optional, Protocol, Union

from .emit import WriteGuard

# Names used by the Template_Project (opus_partner_dv_dbt).
TEMPLATE_NAME = "opus_partner_dv_dbt"
TEMPLATE_PROFILE = "opus_partner_dbt"

MACROS = (
    "generate_schema_name",
    "get_run_date",
    "hash",
    "location_address_key",
    "ma_sat_multi_source",
    "sat_multi_source",
    "stitch_incremental",
    "watermark",
)
MACROS_REL = "macros"
PACKAGES_REL = "dbt_packages"

MODEL_FOLDERS = (
    "models/staging/health",
    "models/raw_vault/standard/staging",
    "models/raw_vault/standard/stitched",
    "models/raw_vault/standard/hubs",
    "models/raw_vault/standard/links",
    "models/raw_vault/standard/satellites",
    "models/raw_vault/standard/references",
    "models/raw_vault/augmented/staging",
    "models/raw_vault/augmented/satellites",
)

SCHEMA = "BGIL_DATA_MODEL"

# Materialization per layer path under models.<project> (Requirement 2.6).
LAYER_MATERIALIZATION = {
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
# Layers that must set +schema themselves (children inherit).
SCHEMA_LAYERS = (
    ("staging",),
    ("raw_vault", "standard"),
    ("raw_vault", "augmented"),
)

# Expected dbt_project.yml template structure. ``_VARS`` stands for one or
# more ``  key: value`` lines; ``_HOOK`` for one ``      - "..."`` line.
_VARS = object()
_HOOK = object()
EXPECTED_DBT_PROJECT = (
    f"name: '{TEMPLATE_NAME}'",
    "version: '1.0.0'",
    "",
    f"profile: '{TEMPLATE_PROFILE}'",
    "",
    'model-paths: ["models"]',
    'analysis-paths: ["analyses"]',
    'test-paths: ["tests"]',
    'seed-paths: ["seeds"]',
    'macro-paths: ["macros"]',
    'snapshot-paths: ["snapshots"]',
    "",
    'target-path: "target"',
    "clean-targets:",
    '  - "target"',
    '  - "dbt_packages"',
    "",
    "vars:",
    _VARS,
    "",
    "",
    "models:",
    f"  {TEMPLATE_NAME}:",
    "    +pre-hook:",
    _HOOK,
    "    +post-hook:",
    _HOOK,
    "    staging:",
    "      +materialized: view",
    f"      +schema: {SCHEMA}",
    '      +tags: ["stg1"]',
    "",
    "    raw_vault:",
    "      standard:",
    f"        +schema: {SCHEMA}",
    "        stitched:",
    "          +materialized: view",
    '          +tags: ["stitch"]',
    "        staging:",
    "          +materialized: view",
    '          +tags: ["standard_stg2"]',
    "        hubs:",
    "          +materialized: incremental",
    '          +tags: ["hub"]',
    "          +on_schema_change: append_new_columns",
    "        links:",
    "          +materialized: incremental",
    '          +tags: ["lnk"]',
    "          +on_schema_change: append_new_columns",
    "        satellites:",
    "          +materialized: incremental",
    '          +tags: ["standard_sat"]',
    "          +on_schema_change: append_new_columns",
    "        references:",
    "          +materialized: view",
    '          +tags: ["ref"]',
    "      augmented:",
    f"        +schema: {SCHEMA}",
    '        +tags: ["aug"]',
    "        staging:",
    "          +materialized: view",
    '          +tags: ["aug_stg2"]',
    "        satellites:",
    "          +materialized: incremental",
    '          +tags: ["aug_sat"]',
    "          +on_schema_change: append_new_columns",
)
_VAR_LINE = re.compile(r"^  [A-Za-z_][A-Za-z0-9_]*: \S+$")
_HOOK_LINE = re.compile(r'^      - ".*"$')

EXPECTED_PACKAGES = (
    "packages:",
    "  - local: dbt_packages/dbt_utils",
    "  - local: dbt_packages/automate_dv",
)

# Any key containing one of these marks a secret (Requirement 2.7).
SECRET_KEY_PARTS = ("password", "token", "private_key", "passphrase", "secret")
_YAML_KEY = re.compile(r"^\s*(?:-\s+)?([A-Za-z_][A-Za-z0-9_\-]*)\s*:")

_NAME_RE = re.compile(r"^[a-z][a-z0-9_]*$")
_VAR_KEY_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
_VAR_VALUE_RE = re.compile(r"^[A-Za-z0-9_]+$")


class ScaffoldConfig(Protocol):
    PROJECT: str
    PROFILE: str
    VARS: Mapping[str, str]
    TEMPLATE_PROJECT: Union[str, Path]


class TemplateMismatch(RuntimeError):
    """A template file does not have the expected structure."""

    def __init__(self, file: str, line_no: int, expected: str, actual: str):
        self.file = file
        self.line_no = line_no
        self.expected = expected
        self.actual = actual
        super().__init__(
            f"template {file} differs from the expected structure at line "
            f"{line_no}:\n  expected: {expected}\n  actual:   {actual}"
        )


class CopyMismatch(RuntimeError):
    """A copied tree's sha256 digests differ from the Template_Project."""

    def __init__(self, what: str, differences: list[str]):
        self.what = what
        self.differences = list(differences)
        listing = "\n".join(f"  - {d}" for d in self.differences)
        super().__init__(f"{what} copy does not match the template:\n{listing}")


class ConfigError(ValueError):
    """The caller's config object has an invalid value."""


@dataclass
class ScaffoldResult:
    template_root: Path
    macro_digests: dict[str, str] = field(default_factory=dict)
    package_digests: dict[str, str] = field(default_factory=dict)
    config_files: dict[str, str] = field(default_factory=dict)
    folders: list[str] = field(default_factory=list)


# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def tree_digests(root: Path) -> dict[str, str]:
    """Return {posix relative path: sha256} for every file under ``root``."""
    out: dict[str, str] = {}
    if not root.is_dir():
        return out
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for name in sorted(filenames):
            path = Path(dirpath) / name
            rel = path.relative_to(root).as_posix()
            out[rel] = _sha256(path.read_bytes())
    return dict(sorted(out.items()))


def _compare(what: str, expected: dict[str, str], actual: dict[str, str]) -> None:
    diffs: list[str] = []
    for rel in sorted(set(expected) | set(actual)):
        if rel not in actual:
            diffs.append(f"{rel}: missing in copy")
        elif rel not in expected:
            diffs.append(f"{rel}: not in template")
        elif expected[rel] != actual[rel]:
            diffs.append(
                f"{rel}: sha256 {actual[rel]} != template {expected[rel]}"
            )
    if diffs:
        raise CopyMismatch(what, diffs)


def _read_text(path: Path) -> str:
    return path.read_bytes().decode("utf-8")


def _show(item) -> str:
    if item is _VARS:
        return "<vars line '  key: value'>"
    if item is _HOOK:
        return '<hook line \'      - "..."\'>'
    return repr(item)


def _strip_trailing_blank(lines: list[str]) -> list[str]:
    end = len(lines)
    while end and not lines[end - 1].strip():
        end -= 1
    return lines[:end]


def _validate_config(cfg: ScaffoldConfig) -> None:
    for attr in ("PROJECT", "PROFILE"):
        value = getattr(cfg, attr, None)
        if not isinstance(value, str) or not _NAME_RE.match(value):
            raise ConfigError(f"config {attr}={value!r} must match {_NAME_RE.pattern}")
    vars_ = getattr(cfg, "VARS", None)
    if not isinstance(vars_, Mapping) or not vars_:
        raise ConfigError("config VARS must be a non-empty mapping")
    for key, value in vars_.items():
        if not isinstance(key, str) or not _VAR_KEY_RE.match(key):
            raise ConfigError(f"config VARS key {key!r} is not a plain identifier")
        if not isinstance(value, str) or not _VAR_VALUE_RE.match(value):
            raise ConfigError(
                f"config VARS[{key!r}]={value!r} must match {_VAR_VALUE_RE.pattern}"
            )


# --------------------------------------------------------------------------
# dbt_project.yml
# --------------------------------------------------------------------------

def _match_dbt_project(lines: list[str], file: str) -> dict[str, object]:
    """Match template lines against EXPECTED_DBT_PROJECT.

    Returns the indexes of the replaced items: ``name``, ``profile``,
    ``models_key`` and ``vars`` (a (start, end) span of the value lines).
    """
    body = _strip_trailing_blank(lines)
    i = 0
    vars_span: Optional[tuple[int, int]] = None
    for item in EXPECTED_DBT_PROJECT:
        actual = body[i] if i < len(body) else "<end of file>"
        if item is _VARS:
            start = i
            while i < len(body) and _VAR_LINE.match(body[i]):
                i += 1
            if i == start:
                raise TemplateMismatch(file, i + 1, _show(item), actual)
            vars_span = (start, i)
            continue
        if item is _HOOK:
            if i >= len(body) or not _HOOK_LINE.match(body[i]):
                raise TemplateMismatch(file, i + 1, _show(item), actual)
            i += 1
            continue
        if i >= len(body) or body[i] != item:
            raise TemplateMismatch(file, i + 1, _show(item), actual)
        i += 1
    if i < len(body):
        raise TemplateMismatch(file, i + 1, "<end of file>", body[i])
    return {
        "name": 0,
        "profile": 3,
        "models_key": body.index(f"  {TEMPLATE_NAME}:"),
        "vars": vars_span,
    }


def render_dbt_project(template_text: str, cfg: ScaffoldConfig,
                       file: str = "dbt_project.yml") -> str:
    """Render dbt_project.yml; only name, profile, models key, vars change."""
    lines = template_text.splitlines()
    idx = _match_dbt_project(lines, file)
    v_start, v_end = idx["vars"]  # type: ignore[misc]
    new_vars = [f"  {k}: {v}" for k, v in cfg.VARS.items()]

    out = list(lines)
    out[idx["name"]] = f"name: '{cfg.PROJECT}'"  # type: ignore[index]
    out[idx["profile"]] = f"profile: '{cfg.PROFILE}'"  # type: ignore[index]
    out[idx["models_key"]] = f"  {cfg.PROJECT}:"  # type: ignore[index]
    out[v_start:v_end] = new_vars

    # Every line outside the replaced items must be unchanged.
    replaced = {idx["name"], idx["profile"], idx["models_key"]}
    shift = len(new_vars) - (v_end - v_start)
    if len(out) != len(lines) + shift:
        raise TemplateMismatch(file, len(lines), f"{len(lines) + shift} lines",
                               f"{len(out)} lines")
    for n, tpl_line in enumerate(lines):
        if n in replaced or v_start <= n < v_end:
            continue
        out_line = out[n if n < v_start else n + shift]
        if out_line != tpl_line:
            raise TemplateMismatch(file, n + 1, tpl_line, out_line)

    text = "\n".join(out) + "\n"
    check_dbt_project_layers(text, cfg.PROJECT, file)
    return text


def check_dbt_project_layers(text: str, project: str,
                             file: str = "dbt_project.yml") -> None:
    """Assert +schema at every layer and the materialization per layer."""
    import yaml  # PyYAML, checked by prereqs.require in run_build

    doc = yaml.safe_load(text) or {}
    root = (doc.get("models") or {}).get(project)
    if not isinstance(root, dict):
        raise TemplateMismatch(file, 0, f"models.{project}", "missing")

    def node(path: tuple[str, ...]):
        cur = root
        for part in path:
            cur = cur.get(part) if isinstance(cur, dict) else None
        return cur if isinstance(cur, dict) else None

    def effective(path: tuple[str, ...], key: str):
        value = root.get(key)
        cur = root
        for part in path:
            cur = cur.get(part) if isinstance(cur, dict) else None
            if isinstance(cur, dict) and key in cur:
                value = cur[key]
        return value

    for path in SCHEMA_LAYERS:
        n = node(path)
        if n is None or n.get("+schema") != SCHEMA:
            raise TemplateMismatch(
                file, 0, f"{'.'.join(path)}.+schema: {SCHEMA}",
                repr(None if n is None else n.get("+schema")),
            )
    for path, mat in LAYER_MATERIALIZATION.items():
        if node(path) is None:
            raise TemplateMismatch(file, 0, ".".join(path), "missing")
        if effective(path, "+schema") != SCHEMA:
            raise TemplateMismatch(
                file, 0, f"{'.'.join(path)} schema {SCHEMA}",
                repr(effective(path, "+schema")),
            )
        if effective(path, "+materialized") != mat:
            raise TemplateMismatch(
                file, 0, f"{'.'.join(path)}.+materialized: {mat}",
                repr(effective(path, "+materialized")),
            )


# --------------------------------------------------------------------------
# packages.yml and profiles.yml
# --------------------------------------------------------------------------

def render_packages(template_text: str, file: str = "packages.yml") -> str:
    """Return packages.yml verbatim after checking its two local entries."""
    content = [ln for ln in template_text.splitlines() if ln.strip()]
    for n, expected in enumerate(EXPECTED_PACKAGES):
        actual = content[n] if n < len(content) else "<end of file>"
        if actual != expected:
            raise TemplateMismatch(file, n + 1, expected, actual)
    if len(content) > len(EXPECTED_PACKAGES):
        raise TemplateMismatch(
            file, len(EXPECTED_PACKAGES) + 1, "<end of file>",
            content[len(EXPECTED_PACKAGES)],
        )
    return template_text


def find_secret_keys(text: str) -> list[tuple[int, str]]:
    """Return (line number, key) for every key that looks like a secret."""
    found: list[tuple[int, str]] = []
    for n, line in enumerate(text.splitlines(), start=1):
        m = _YAML_KEY.match(line.split("#", 1)[0])
        if m and any(part in m.group(1).lower() for part in SECRET_KEY_PARTS):
            found.append((n, m.group(1)))
    return found


def render_profiles(template_text: str, cfg: ScaffoldConfig,
                    file: str = "profiles.yml") -> str:
    """Rename the top key of profiles.yml; refuse any secret field."""
    lines = template_text.splitlines()
    first = next((n for n, ln in enumerate(lines) if ln.strip()), None)
    expected_top = f"{TEMPLATE_PROFILE}:"
    if first is None or lines[first] != expected_top:
        raise TemplateMismatch(
            file, (first or 0) + 1, expected_top,
            "<end of file>" if first is None else lines[first],
        )
    for n, ln in enumerate(lines):
        if n != first and ln.strip() and not ln[0].isspace() \
                and not ln.lstrip().startswith("#"):
            raise TemplateMismatch(file, n + 1, "<indented line>", ln)
        if n != first and TEMPLATE_PROFILE in ln:
            raise TemplateMismatch(
                file, n + 1, f"no other use of {TEMPLATE_PROFILE}", ln
            )
    secrets = find_secret_keys(template_text)
    if secrets:
        n, key = secrets[0]
        raise TemplateMismatch(file, n, "no password, token or key field", key)
    out = list(lines)
    out[first] = f"{cfg.PROFILE}:"
    return "\n".join(out) + "\n"


# --------------------------------------------------------------------------
# entry point
# --------------------------------------------------------------------------

def template_root_for(cfg: ScaffoldConfig, project_root: Path) -> Path:
    tpl = Path(cfg.TEMPLATE_PROJECT)
    if not tpl.is_absolute():
        tpl = project_root / tpl
    return tpl.resolve()


def scaffold(cfg: ScaffoldConfig, project_root: Union[str, Path],
             guard: Optional[WriteGuard] = None) -> ScaffoldResult:
    """Scaffold ``project_root`` from the Template_Project named in ``cfg``."""
    _validate_config(cfg)
    guard = guard or WriteGuard(project_root)
    root = guard.root
    tpl = template_root_for(cfg, root)
    if tpl == root:
        raise ConfigError("TEMPLATE_PROJECT must differ from the project root")
    if not tpl.is_dir():
        raise ConfigError(f"Template_Project not found: {tpl}")
    result = ScaffoldResult(template_root=tpl)

    # Read and render every config file before writing anything, so a
    # template mismatch stops the scaffold with no partial output.
    texts = {
        "dbt_project.yml": render_dbt_project(
            _read_text(tpl / "dbt_project.yml"), cfg),
        "packages.yml": render_packages(_read_text(tpl / "packages.yml")),
        "profiles.yml": render_profiles(_read_text(tpl / "profiles.yml"), cfg),
    }
    for name in MACROS:
        src = tpl / MACROS_REL / f"{name}.sql"
        if not src.is_file():
            raise TemplateMismatch(f"{MACROS_REL}/{name}.sql", 0,
                                   "file exists", "missing")
    tpl_packages = tpl / PACKAGES_REL
    if not tpl_packages.is_dir():
        raise TemplateMismatch(PACKAGES_REL, 0, "folder exists", "missing")

    # Macros (Requirement 2.4).
    expected_macros: dict[str, str] = {}
    for name in MACROS:
        rel = f"{name}.sql"
        data = (tpl / MACROS_REL / rel).read_bytes()
        expected_macros[rel] = _sha256(data)
        guard.write_bytes(f"{MACROS_REL}/{rel}", data)
    actual_macros = {
        rel: _sha256((root / MACROS_REL / rel).read_bytes())
        for rel in expected_macros
    }
    _compare(MACROS_REL, expected_macros, actual_macros)
    result.macro_digests = actual_macros

    # dbt_packages/ (Requirement 2.3).
    expected_pkgs = tree_digests(tpl_packages)
    for rel in expected_pkgs:
        guard.write_bytes(f"{PACKAGES_REL}/{rel}",
                          (tpl_packages / rel).read_bytes())
    actual_pkgs = tree_digests(guard.resolve(PACKAGES_REL))
    _compare(PACKAGES_REL, expected_pkgs, actual_pkgs)
    result.package_digests = actual_pkgs

    # Config files (Requirements 2.1, 2.2, 2.6, 2.7).
    for rel, text in texts.items():
        result.config_files[rel] = guard.write(rel, text)

    # Folder layout (Requirement 2.5).
    for rel in MODEL_FOLDERS:
        guard.resolve(rel).mkdir(parents=True, exist_ok=True)
        result.folders.append(rel)

    return result
