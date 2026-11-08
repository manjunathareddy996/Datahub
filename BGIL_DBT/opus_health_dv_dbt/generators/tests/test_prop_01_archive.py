"""Property test for ``archive_legacy.archive``.

Feature: health-lob-dv-dbt-build, Property 1: Archive preserves every file

For any project tree, running the archive step yields, for every file
previously under ``models/`` or ``generators/``, a file at
``legacy_v3/<same relative path>`` with the same sha256, and every file
outside those two folders keeps its path and sha256.

**Validates: Requirements 1.1, 1.2, 1.3**
"""
from __future__ import annotations

import hashlib
import json
import os
import tempfile
from pathlib import Path

from hypothesis import HealthCheck, given, settings
from hypothesis import strategies as st

import archive_legacy

# Names carry a "d_" / "f_" prefix so a file and a folder can never share a
# path, and no name can be a reserved Windows device name (con, nul, ...).
_STEM = st.text(alphabet="abcdefghijklmnopqrstuvwxyz0123456789_-", min_size=1, max_size=6)
_DIR = _STEM.map(lambda s: "d_" + s)
_FILE = st.tuples(_STEM, st.sampled_from([".sql", ".py", ".json", ".md", ".pyc", ""])).map(
    lambda t: "f_" + t[0] + t[1]
)
_CONTENT = st.binary(max_size=256)


@st.composite
def _subtree(draw) -> dict[str, bytes]:
    """{relative posix path: bytes}; may be empty, up to 3 folders deep."""
    entries = draw(
        st.lists(
            st.tuples(st.lists(_DIR, max_size=3), _FILE, _CONTENT),
            max_size=8,
        )
    )
    return {"/".join([*dirs, name]): data for dirs, name, data in entries}


@st.composite
def _project(draw) -> dict:
    tree = {
        # Archived folders always exist (archive requires them); they may be empty.
        "models": draw(_subtree()),
        "generators": draw(_subtree()),
        # Decoy folders that must stay where they are.
        "inputs": draw(st.one_of(st.none(), _subtree())),
        "build_artifacts": draw(st.one_of(st.none(), _subtree())),
    }
    # Other top-level folders, e.g. "models_old" or "d_x", also stay put.
    for name in draw(st.lists(st.sampled_from(["models_old", "generators.bak", "d_x", "macros"]),
                              unique=True, max_size=2)):
        tree[name] = draw(_subtree())
    root_files = draw(
        st.dictionaries(st.sampled_from(["f_readme.md", "f_dbt.yml", "archive_legacy.py"]),
                        _CONTENT, max_size=2)
    )
    profile = draw(st.one_of(st.none(), _CONTENT))
    if profile is not None:
        root_files["build_profile.json"] = profile
    return {"folders": tree, "root_files": root_files}


def _write(root: Path, project: dict) -> None:
    for folder, files in project["folders"].items():
        if files is None:
            continue
        (root / folder).mkdir()
        for rel, data in files.items():
            path = root / folder / rel
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
    for name, data in project["root_files"].items():
        (root / name).write_bytes(data)


def _snapshot(root: Path) -> dict[str, str]:
    """{posix path relative to root: sha256} for every file under root."""
    out = {}
    for dirpath, _dirs, files in os.walk(root):
        for fn in files:
            full = Path(dirpath) / fn
            out[full.relative_to(root).as_posix()] = hashlib.sha256(full.read_bytes()).hexdigest()
    return out


@settings(max_examples=150, deadline=None,
          suppress_health_check=[HealthCheck.function_scoped_fixture, HealthCheck.too_slow])
@given(project=_project())
def test_archive_preserves_every_file(tmp_path, project):
    """Feature: health-lob-dv-dbt-build, Property 1: Archive preserves every file"""
    root = Path(tempfile.mkdtemp(dir=tmp_path))
    _write(root, project)
    before = _snapshot(root)

    result = archive_legacy.archive(root)

    after = _snapshot(root)
    archived = {p: d for p, d in before.items()
                if p.startswith(("models/", "generators/"))}
    untouched = {p: d for p, d in before.items() if p not in archived}

    # 1.1: the source folders are gone from the project root.
    assert not (root / "models").exists()
    assert not (root / "generators").exists()

    # 1.2: every archived file sits at legacy_v3/<same path> with the same sha256.
    for rel, digest in archived.items():
        assert after.get(f"legacy_v3/{rel}") == digest, rel

    # 1.3: every file outside models/ and generators/ keeps its path and sha256.
    for rel, digest in untouched.items():
        assert after.get(rel) == digest, rel
    for name in ("inputs", "build_artifacts"):
        assert (root / name).is_dir() == (project["folders"][name] is not None)
    assert (root / "build_profile.json").is_file() == ("build_profile.json" in project["root_files"])

    # Nothing else appeared apart from the archived files and the manifest.
    expected = set(untouched) | {f"legacy_v3/{p}" for p in archived} | {
        "legacy_v3/ARCHIVE_MANIFEST.json"}
    assert set(after) == expected

    # The manifest and the result list exactly the archived files and digests.
    manifest = json.loads((root / "legacy_v3" / "ARCHIVE_MANIFEST.json").read_text("utf-8"))
    assert {f["path"]: f["sha256"] for f in manifest["files"]} == archived
    assert manifest["total_files"] == len(archived)
    assert result.files == archived
