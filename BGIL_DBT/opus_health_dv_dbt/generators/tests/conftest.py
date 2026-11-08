"""Shared pytest setup for the Builder tests.

- Puts ``generators/`` and the project root on ``sys.path`` so tests can
  import ``dvgen``, ``project_config`` and root scripts such as
  ``archive_legacy``.
- Keeps every test write inside ``tmp_path``: each test runs with the
  working directory, ``TMP``/``TEMP``/``TMPDIR`` and ``tempfile.tempdir``
  pointed at ``tmp_path``, and an audit hook fails any file write, delete,
  rename or mkdir outside ``tmp_path`` while the test runs.

This file is byte-identical in both Health_Projects (Requirement 10.3).
"""
from __future__ import annotations

import os
import sys
import tempfile
from pathlib import Path

import pytest

GENERATORS_DIR = Path(__file__).resolve().parent.parent
PROJECT_ROOT = GENERATORS_DIR.parent

for _p in (str(PROJECT_ROOT), str(GENERATORS_DIR)):
    if _p not in sys.path:
        sys.path.insert(0, _p)

# Importing modules during a test must not write __pycache__ outside tmp_path.
sys.dont_write_bytecode = True

try:  # Hypothesis must not create .hypothesis/ in the project.
    from hypothesis import settings as _hyp_settings

    _hyp_settings.register_profile("health_dv", database=None)
    _hyp_settings.load_profile("health_dv")
except ImportError:  # pragma: no cover - hypothesis is a stated prerequisite
    pass


# --------------------------------------------------------------------------
# Write guard
# --------------------------------------------------------------------------

class OutsideTmpWrite(PermissionError):
    """A test tried to change the file system outside its tmp_path."""


_WRITE_FLAGS = (
    os.O_WRONLY | os.O_RDWR | os.O_APPEND | os.O_CREAT | os.O_TRUNC
)
_GUARD = {"root": None, "busy": False}


def _norm(path) -> str | None:
    if isinstance(path, int):
        return None  # already-open file descriptor
    try:
        p = os.fsdecode(os.fspath(path))
    except TypeError:
        return None
    return os.path.normcase(os.path.abspath(p))


def _inside(path) -> bool:
    norm = _norm(path)
    if norm is None or norm == os.path.normcase(os.devnull):
        return True
    root = _GUARD["root"]
    return norm == root or norm.startswith(root + os.sep)


def _is_write_open(mode, flags) -> bool:
    if isinstance(mode, str) and any(c in mode for c in "wax+"):
        return True
    return isinstance(flags, int) and bool(flags & _WRITE_FLAGS)


def _audit(event: str, args) -> None:
    if _GUARD["root"] is None or _GUARD["busy"]:
        return
    _GUARD["busy"] = True
    try:
        targets = ()
        if event == "open":
            path, mode, flags = args
            if _is_write_open(mode, flags):
                targets = (path,)
        elif event in ("os.remove", "os.rmdir", "os.mkdir", "os.truncate",
                       "os.chmod", "os.utime", "shutil.rmtree"):
            targets = (args[0],)
        elif event in ("os.rename", "os.link", "os.symlink"):
            targets = (args[0], args[1])
        elif event == "shutil.copyfile":
            targets = (args[1],)
        for target in targets:
            if not _inside(target):
                raise OutsideTmpWrite(
                    f"test write outside tmp_path ({event}): {target!r}; "
                    f"allowed root: {_GUARD['root']}"
                )
    finally:
        _GUARD["busy"] = False


sys.addaudithook(_audit)


@pytest.fixture(autouse=True)
def _confine_writes_to_tmp_path(tmp_path, monkeypatch):
    """Run each test with all writes confined to ``tmp_path``."""
    monkeypatch.chdir(tmp_path)
    for var in ("TMP", "TEMP", "TMPDIR"):
        monkeypatch.setenv(var, str(tmp_path))
    monkeypatch.setattr(tempfile, "tempdir", str(tmp_path))
    _GUARD["root"] = os.path.normcase(os.path.abspath(str(tmp_path)))
    try:
        yield tmp_path
    finally:
        _GUARD["root"] = None
