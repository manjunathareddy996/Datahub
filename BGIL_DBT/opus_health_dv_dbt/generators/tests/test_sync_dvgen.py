"""Unit tests for ``sync_dvgen`` using fake project trees under tmp_path."""
from __future__ import annotations

import hashlib

import pytest

import sync_dvgen
from dvgen.emit import WriteGuard
from sync_dvgen import DigestMismatch, SyncResult, main, sync


def _put(root, rel, data):
    p = root / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(data if isinstance(data, bytes) else data.encode())
    return p


def _snapshot(root):
    return {
        p.relative_to(root).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted(root.rglob("*")) if p.is_file()
    }


@pytest.fixture
def trees(tmp_path):
    src = tmp_path / "opus"
    dst = tmp_path / "maximus"
    _put(src, "generators/dvgen/__init__.py", b"a\r\nb\r\n")  # CRLF kept
    _put(src, "generators/dvgen/sub/mod.py", b"mod = 1\n")
    _put(src, "generators/dvgen/__pycache__/x.pyc", b"junk")
    _put(src, "generators/tests/test_a.py", b"def test_a(): pass\n")
    _put(src, "generators/tests/test_adapter_hcon.py", b"hcon\n")
    _put(src, "generators/run_build.py", b"run\n")
    _put(src, "verify_health.py", b"verify\n")
    _put(src, "generators/project_config.py", b"SRC_CONFIG\n")
    _put(src, "generators/adapter_hcon.py", b"SRC_ADAPTER\n")
    # destination
    _put(dst, "generators/dvgen/__init__.py", b"old\n")
    _put(dst, "generators/dvgen/stale.py", b"stale\n")
    _put(dst, "generators/dvgen/sub/gone.py", b"gone\n")
    _put(dst, "generators/dvgen/__pycache__/keep.pyc", b"cache")
    _put(dst, "generators/tests/test_old.py", b"old\n")
    _put(dst, "generators/project_config.py", b"DST_CONFIG\n")
    _put(dst, "generators/adapter_mxh3.py", b"DST_ADAPTER\n")
    _put(dst, "models/m.sql", b"select 1\n")
    _put(dst, "build_artifacts/x.json", b"{}")
    _put(dst, "legacy_v3/l.py", b"legacy\n")
    _put(dst, "inputs/i.csv", b"a,b\n")
    return src, dst


def test_copies_byte_for_byte_and_removes_stale(trees):
    src, dst = trees
    res = sync(src, dst)
    assert res.ok
    assert (dst / "generators/dvgen/__init__.py").read_bytes() == b"a\r\nb\r\n"
    assert (dst / "generators/dvgen/sub/mod.py").read_bytes() == b"mod = 1\n"
    assert (dst / "generators/tests/test_adapter_hcon.py").read_bytes() == b"hcon\n"
    assert (dst / "generators/run_build.py").read_bytes() == b"run\n"
    assert (dst / "verify_health.py").read_bytes() == b"verify\n"
    assert not (dst / "generators/dvgen/stale.py").exists()
    assert not (dst / "generators/dvgen/sub/gone.py").exists()
    assert not (dst / "generators/tests/test_old.py").exists()
    assert sorted(res.removed) == [
        "generators/dvgen/stale.py",
        "generators/dvgen/sub/gone.py",
        "generators/tests/test_old.py",
    ]
    assert len(res.copied) == 6
    assert "generators/dvgen/__pycache__/x.pyc" not in res.copied
    assert not (dst / "generators/dvgen/__pycache__/x.pyc").exists()
    # ignored destination caches are neither removed nor compared
    assert (dst / "generators/dvgen/__pycache__/keep.pyc").exists()


def test_idempotent(trees):
    src, dst = trees
    sync(src, dst)
    before = _snapshot(dst)
    res = sync(src, dst)
    assert res.copied == [] and res.removed == [] and res.ok
    assert len(res.unchanged) == 6
    assert _snapshot(dst) == before


def test_project_config_adapters_and_other_dirs_untouched(trees):
    src, dst = trees
    keep = {
        k: v for k, v in _snapshot(dst).items()
        if k.startswith(("models/", "build_artifacts/", "legacy_v3/", "inputs/"))
        or k in ("generators/project_config.py", "generators/adapter_mxh3.py")
    }
    sync(src, dst)
    after = _snapshot(dst)
    for k, v in keep.items():
        assert after[k] == v
    assert not (dst / "generators/adapter_hcon.py").exists()
    assert (dst / "generators/project_config.py").read_bytes() == b"DST_CONFIG\n"


def test_protected_names_inside_synced_dirs_not_copied_or_removed(trees):
    src, dst = trees
    _put(src, "generators/tests/project_config.py", b"S\n")
    _put(dst, "generators/tests/adapter_x.py", b"D\n")
    sync(src, dst)
    assert not (dst / "generators/tests/project_config.py").exists()
    assert (dst / "generators/tests/adapter_x.py").exists()


def test_missing_sources_are_skipped(tmp_path):
    src = tmp_path / "opus"
    dst = tmp_path / "maximus"
    _put(src, "generators/dvgen/m.py", b"m\n")
    _put(dst, "generators/run_build.py", b"keep me\n")
    _put(dst, "generators/tests/t.py", b"keep tests\n")
    res = sync(src, dst)
    assert res.ok
    assert sorted(res.skipped) == [
        "generators/run_build.py",
        "generators/tests/",
        "verify_health.py",
    ]
    # nothing deleted for a source that does not exist yet
    assert (dst / "generators/run_build.py").read_bytes() == b"keep me\n"
    assert (dst / "generators/tests/t.py").exists()
    assert (dst / "generators/dvgen/m.py").exists()


def test_digest_mismatch_reported(trees):
    src, dst = trees

    class Corrupting(WriteGuard):
        def write_bytes(self, rel_path, data):
            return super().write_bytes(rel_path, data + b"x")

    res = sync(src, dst, guard=Corrupting(dst))
    assert not res.ok
    assert "verify_health.py" in res.mismatches


def test_main_nonzero_on_mismatch_and_zero_on_success(trees, monkeypatch, capsys):
    src, dst = trees
    monkeypatch.setattr(sync_dvgen, "_HERE", src / "generators")
    assert main([str(dst)]) == 0
    assert "copied=" in capsys.readouterr().out

    real_sync = sync_dvgen.sync

    def bad_sync(s, d, guard=None):
        r = real_sync(s, d, guard)
        r.mismatches.append("verify_health.py")
        return r

    monkeypatch.setattr(sync_dvgen, "sync", bad_sync)
    assert main([str(dst)]) == 1


def test_main_missing_destination(tmp_path, capsys):
    assert main([str(tmp_path / "nope")]) == 2


def test_digest_mismatch_exception_lists_paths():
    err = DigestMismatch(["a", "b"])
    assert "a" in str(err) and err.paths == ["a", "b"]
    assert isinstance(SyncResult().summary(), str)
