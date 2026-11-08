"""Unit test: archive_legacy refuses to run when legacy_v3/ already exists.

Validates: Requirements 1.4
"""
from __future__ import annotations

import hashlib
import os
from pathlib import Path

import pytest

import archive_legacy
from archive_legacy import ArchiveExists, archive


def _snapshot(root: Path) -> dict[str, str | None]:
    """Map every file and folder under root to its sha256 (None for folders)."""
    snap: dict[str, str | None] = {}
    for dirpath, dirnames, filenames in os.walk(root):
        base = Path(dirpath)
        for d in dirnames:
            snap[(base / d).relative_to(root).as_posix() + "/"] = None
        for f in filenames:
            full = base / f
            snap[full.relative_to(root).as_posix()] = hashlib.sha256(
                full.read_bytes()
            ).hexdigest()
    return snap


def _make_project(root: Path) -> None:
    files = {
        "models/staging/stg_a.sql": "select 1 as a\n",
        "models/raw_vault/hub_a.sql": "select 2 as b\n",
        "generators/build.py": "print('old builder')\n",
        "build_artifacts/hcon_spec.json": '{"meta": {}}\n',
        "inputs/map.json": "[]\n",
        "build_profile.json": "{}\n",
        "legacy_v3/models/old.sql": "select 0\n",
        "legacy_v3/ARCHIVE_MANIFEST.json": '{"files": []}\n',
    }
    for rel, text in files.items():
        p = root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text, encoding="utf-8", newline="\n")


def test_archive_refuses_when_legacy_exists(tmp_path):
    project = tmp_path / "proj"
    _make_project(project)
    before = _snapshot(project)

    with pytest.raises(ArchiveExists) as excinfo:
        archive(project)

    expected = (project / "legacy_v3").resolve()
    assert excinfo.value.path == expected
    assert str(expected) in str(excinfo.value)
    assert _snapshot(project) == before


def test_archive_refuses_when_legacy_is_empty_folder(tmp_path):
    project = tmp_path / "proj"
    (project / "models").mkdir(parents=True)
    (project / "models" / "m.sql").write_text("select 1\n", encoding="utf-8")
    (project / "generators").mkdir()
    (project / "legacy_v3").mkdir()
    before = _snapshot(project)

    with pytest.raises(ArchiveExists) as excinfo:
        archive(project)

    assert excinfo.value.path == (project / "legacy_v3").resolve()
    assert _snapshot(project) == before


def test_main_exits_nonzero_and_names_path(tmp_path, capsys):
    project = tmp_path / "proj"
    _make_project(project)
    before = _snapshot(project)

    code = archive_legacy.main(["archive_legacy.py", str(project)])

    assert code != 0
    err = capsys.readouterr().err
    assert str((project / "legacy_v3").resolve()) in err
    assert "Nothing was moved" in err
    assert _snapshot(project) == before
