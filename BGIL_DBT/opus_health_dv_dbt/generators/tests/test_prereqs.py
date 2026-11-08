"""Unit tests for dvgen.prereqs and the conftest write guard."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

from dvgen import prereqs
from dvgen.prereqs import PrereqMissing, require

import conftest


def test_require_returns_imported_modules():
    mods = require(["json", "os.path"])
    assert mods["json"].__name__ == "json"
    assert set(mods) == {"json", "os.path"}


def test_require_accepts_single_name():
    assert "json" in require("json")


def test_require_build_modules_are_importable():
    assert set(require(prereqs.BUILD_MODULES)) == set(prereqs.BUILD_MODULES)


def test_require_names_every_missing_module_with_install_hint():
    with pytest.raises(PrereqMissing) as info:
        require(["json", "dvgen_no_such_mod_a", "yaml", "dvgen_no_such_mod_b"])
    err = info.value
    assert err.modules == ["dvgen_no_such_mod_a", "dvgen_no_such_mod_b"]
    msg = str(err)
    assert "dvgen_no_such_mod_a" in msg and "dvgen_no_such_mod_b" in msg
    assert f'"{sys.executable}" -m pip install' in msg
    assert isinstance(err, ImportError)


def test_pip_hint_uses_distribution_name():
    assert prereqs.pip_name("yaml") == "PyYAML"
    assert prereqs.pip_name("openpyxl.styles") == "openpyxl"


def test_require_never_installs(monkeypatch):
    def _fail(*args, **kwargs):
        raise AssertionError("require() must not start a process")

    for name in ("run", "Popen", "call", "check_call", "check_output"):
        monkeypatch.setattr(subprocess, name, _fail)
    with pytest.raises(PrereqMissing):
        require("dvgen_no_such_mod_c")


def test_sys_path_has_generators_and_project_root():
    paths = {str(Path(p).resolve()) for p in sys.path if p}
    assert str(conftest.GENERATORS_DIR) in paths
    assert str(conftest.PROJECT_ROOT) in paths
    assert (conftest.PROJECT_ROOT / "archive_legacy.py").is_file()


def test_writes_inside_tmp_path_are_allowed(tmp_path):
    assert Path.cwd() == tmp_path
    Path("relative.txt").write_text("x", encoding="utf-8")
    (tmp_path / "sub").mkdir()
    (tmp_path / "sub" / "f.txt").write_text("y", encoding="utf-8")
    assert (tmp_path / "relative.txt").read_text(encoding="utf-8") == "x"


def test_writes_outside_tmp_path_are_blocked(tmp_path):
    outside = tmp_path.parent / f"{tmp_path.name}_outside.txt"
    with pytest.raises(conftest.OutsideTmpWrite):
        outside.write_text("x", encoding="utf-8")
    with pytest.raises(conftest.OutsideTmpWrite):
        (conftest.GENERATORS_DIR / "should_not_exist").mkdir()
    assert not outside.exists()
    assert not (conftest.GENERATORS_DIR / "should_not_exist").exists()


def test_reads_outside_tmp_path_are_allowed():
    text = (conftest.GENERATORS_DIR / "dvgen" / "prereqs.py").read_text(
        encoding="utf-8"
    )
    assert "def require" in text
