#!/usr/bin/env python3
"""Sync the shared Builder core from OPUS_Project into MAXIMUS_Project.

Sync set (byte-for-byte copy, relative to each project root):

* ``generators/dvgen/**``
* ``generators/tests/**``
* ``generators/run_build.py``
* ``verify_health.py``

Files under the destination's ``generators/dvgen/`` and ``generators/tests/``
that are absent from the source are removed. A source file that does not
exist yet is skipped. ``project_config.py``, the adapters and everything
else in the destination are never touched. ``__pycache__``, ``*.pyc``,
``.hypothesis`` and ``.pytest_cache`` are ignored for copy, removal and
comparison.

All writes and deletes go through ``dvgen.emit.WriteGuard`` rooted at the
destination project, so nothing outside it can change (Requirement 10.3).
After the copy the digests of every sync-set file are compared; any
difference makes ``main`` exit non-zero (Requirements 5.9, 10.1).

Usage: ``python generators/sync_dvgen.py [DEST_PROJECT_ROOT]``
"""
from __future__ import annotations

import hashlib
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterator, Optional, Union

_HERE = Path(__file__).resolve().parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

from dvgen.emit import WriteGuard  # noqa: E402

SYNC_DIRS = ("generators/dvgen", "generators/tests")
SYNC_FILES = ("generators/run_build.py", "verify_health.py")
# Never copied or removed, even if they appear under a synced directory.
PROTECTED_NAMES = frozenset({"project_config.py"})
PROTECTED_PREFIXES = ("adapter_",)
IGNORED_DIRS = frozenset({"__pycache__", ".hypothesis", ".pytest_cache"})
IGNORED_SUFFIXES = (".pyc",)

DEFAULT_DEST = (_HERE.parent.parent / "maximus_health_dv_dbt").resolve()


class DigestMismatch(RuntimeError):
    """Post-copy comparison found files that differ."""

    def __init__(self, paths: list[str]):
        self.paths = list(paths)
        super().__init__(
            "digest mismatch after sync:\n" + "\n".join(f"  - {p}" for p in paths)
        )


@dataclass
class SyncResult:
    copied: list[str] = field(default_factory=list)
    unchanged: list[str] = field(default_factory=list)
    removed: list[str] = field(default_factory=list)
    skipped: list[str] = field(default_factory=list)
    mismatches: list[str] = field(default_factory=list)

    @property
    def ok(self) -> bool:
        return not self.mismatches

    def summary(self) -> str:
        return (
            f"copied={len(self.copied)} unchanged={len(self.unchanged)} "
            f"removed={len(self.removed)} skipped={len(self.skipped)} "
            f"mismatches={len(self.mismatches)}"
        )


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _is_protected(name: str) -> bool:
    return name in PROTECTED_NAMES or name.startswith(PROTECTED_PREFIXES)


def _is_ignored(rel_parts: tuple[str, ...]) -> bool:
    if any(p in IGNORED_DIRS for p in rel_parts[:-1]):
        return True
    return rel_parts[-1].endswith(IGNORED_SUFFIXES) or rel_parts[-1] in IGNORED_DIRS


def _walk(root: Path, rel_dir: str) -> Iterator[str]:
    """Yield posix paths (relative to ``root``) of syncable files in ``rel_dir``."""
    base = root / rel_dir
    if not base.is_dir():
        return
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames[:] = sorted(d for d in dirnames if d not in IGNORED_DIRS)
        for name in sorted(filenames):
            full = Path(dirpath) / name
            rel = full.relative_to(root)
            if _is_ignored(rel.parts) or _is_protected(name):
                continue
            yield rel.as_posix()


def _source_files(src: Path) -> tuple[list[str], list[str]]:
    """Return (existing source files, missing sync-set files)."""
    found: list[str] = []
    missing: list[str] = []
    for d in SYNC_DIRS:
        files = list(_walk(src, d))
        if not files and not (src / d).is_dir():
            missing.append(d + "/")
        found.extend(files)
    for f in SYNC_FILES:
        (found if (src / f).is_file() else missing).append(f)
    return sorted(found), sorted(missing)


def sync(
    src_root: Union[str, Path],
    dst_root: Union[str, Path],
    guard: Optional[WriteGuard] = None,
) -> SyncResult:
    """Copy the sync set from ``src_root`` to ``dst_root``; return the outcome.

    ``result.mismatches`` lists files whose digests differ after the copy.
    """
    src = Path(src_root).resolve()
    dst = Path(dst_root).resolve()
    guard = guard or WriteGuard(dst)
    result = SyncResult()

    sources, missing = _source_files(src)
    result.skipped.extend(missing)

    for rel in sources:
        data = (src / rel).read_bytes()
        target = dst / rel
        if target.is_file() and target.read_bytes() == data:
            result.unchanged.append(rel)
            continue
        guard.write_bytes(rel, data)
        result.copied.append(rel)

    # Remove destination-only files in the synced directories.
    wanted = set(sources)
    for d in SYNC_DIRS:
        if not (src / d).is_dir():
            continue  # source folder missing: leave destination alone
        for rel in list(_walk(dst, d)):
            if rel not in wanted:
                guard.resolve(rel).unlink()
                result.removed.append(rel)
        _prune_empty_dirs(dst / d)

    # Compare digests of every sync-set file.
    for rel in sources:
        target = dst / rel
        if not target.is_file() or _sha256(target) != _sha256(src / rel):
            result.mismatches.append(rel)
    return result


def _prune_empty_dirs(base: Path) -> None:
    if not base.is_dir():
        return
    for dirpath, _dirnames, _files in os.walk(base, topdown=False):
        p = Path(dirpath)
        if p != base and not any(p.iterdir()):
            p.rmdir()


def main(argv: Optional[list[str]] = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)
    dst = Path(args[0]).resolve() if args else DEFAULT_DEST
    src = _HERE.parent
    if not dst.is_dir():
        print(f"destination project not found: {dst}", file=sys.stderr)
        return 2
    result = sync(src, dst)
    for label, items in (
        ("copied", result.copied),
        ("removed", result.removed),
        ("skipped (missing in source)", result.skipped),
        ("MISMATCH", result.mismatches),
    ):
        for item in items:
            print(f"{label}: {item}")
    print(result.summary())
    return 0 if result.ok else 1


if __name__ == "__main__":
    sys.exit(main())
