"""Unit tests for dvgen.emit (Requirements 10.1, 10.2, 10.3)."""
from __future__ import annotations

import hashlib
import json

import pytest

from dvgen.emit import (
    MANIFEST_REL,
    DuplicateWrite,
    OutsideProject,
    UntrackedModelFile,
    WriteGuard,
    generated_header,
    has_generated_header,
)

HDR = generated_header("render_test")


@pytest.fixture
def root(tmp_path):
    r = tmp_path / "proj"
    r.mkdir()
    return r


def test_write_uses_utf8_lf_and_returns_sha256(root):
    guard = WriteGuard(root)
    digest = guard.write("models/a.sql", f"{HDR}\r\nselect 'é'\rfrom x\n")
    data = (root / "models" / "a.sql").read_bytes()
    assert data == f"{HDR}\nselect 'é'\nfrom x\n".encode("utf-8")
    assert digest == hashlib.sha256(data).hexdigest()


@pytest.mark.parametrize(
    "bad",
    ["../escape.sql", "models/../../escape.sql", "..\\escape.sql", "", "."],
)
def test_write_outside_root_raises_and_writes_nothing(root, bad):
    guard = WriteGuard(root)
    with pytest.raises(OutsideProject):
        guard.write(bad, "x\n")
    assert not (root.parent / "escape.sql").exists()
    assert guard.written == {}


def test_absolute_path_outside_root_raises(root):
    guard = WriteGuard(root)
    outside = root.parent / "abs.sql"
    with pytest.raises(OutsideProject):
        guard.write(str(outside), "x\n")
    assert not outside.exists()


def test_dotdot_that_stays_inside_is_allowed(root):
    guard = WriteGuard(root)
    guard.write("models/x/../b.sql", "x\n")
    assert (root / "models" / "b.sql").is_file()
    assert list(guard.written) == ["models/b.sql"]


def test_manifest_is_sorted_and_deterministic(root):
    texts = {"models/z.sql": "z\n", "dbt_project.yml": "y\n", "models/a.sql": "a\n"}
    outputs = []
    for order in (sorted(texts), sorted(texts, reverse=True)):
        guard = WriteGuard(root)
        for p in order:
            guard.write(p, texts[p])
        guard.write_manifest()
        outputs.append((root / MANIFEST_REL).read_bytes())
    assert outputs[0] == outputs[1]
    files = json.loads(outputs[0])["files"]
    assert [f["path"] for f in files] == sorted(texts)
    assert files[0]["sha256"] == hashlib.sha256(b"y\n").hexdigest()


def test_duplicate_write_with_different_text_raises(root):
    guard = WriteGuard(root)
    guard.write("models/a.sql", "a\n")
    guard.write("models/a.sql", "a\n")
    with pytest.raises(DuplicateWrite):
        guard.write("models/a.sql", "b\n")


def test_header_detection_allows_config_line_and_yaml_marker():
    assert has_generated_header(f"{HDR}\nselect 1\n")
    assert has_generated_header("{{ config(materialized='view') }}\n" + HDR + "\n")
    assert has_generated_header(generated_header("scaffold", "#") + "\nversion: 2\n")
    assert not has_generated_header("select 1\n" + HDR + "\n")
    assert not has_generated_header("")


def test_remove_stale_deletes_only_unplanned_generated_files(root):
    old = root / "models" / "old"
    old.mkdir(parents=True)
    (old / "stale.sql").write_text(f"{HDR}\nselect 1\n", encoding="utf-8")
    guard = WriteGuard(root)
    guard.write("models/keep.sql", f"{HDR}\nselect 2\n")
    assert guard.remove_stale() == ["models/old/stale.sql"]
    assert not (old / "stale.sql").exists()
    assert (root / "models" / "keep.sql").is_file()


def test_hand_written_model_stops_build_and_nothing_is_deleted(root):
    models = root / "models"
    models.mkdir()
    (models / "stale.sql").write_text(f"{HDR}\n", encoding="utf-8")
    (models / "hand.sql").write_text("select 1\n", encoding="utf-8")
    guard = WriteGuard(root)
    with pytest.raises(UntrackedModelFile) as info:
        guard.remove_stale()
    assert info.value.paths == ["models/hand.sql"]
    assert "models/hand.sql" in str(info.value)
    assert (models / "stale.sql").exists()


def test_remove_stale_respects_explicit_plan(root):
    models = root / "models"
    models.mkdir()
    (models / "planned.sql").write_text(f"{HDR}\n", encoding="utf-8")
    guard = WriteGuard(root)
    assert guard.remove_stale(planned=["models/planned.sql"]) == []
    assert (models / "planned.sql").exists()
