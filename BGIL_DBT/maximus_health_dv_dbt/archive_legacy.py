"""One-off archive of the pre-rebuild Health_Project build.

Moves ``models/`` and ``generators/`` into ``legacy_v3/``, writes
``legacy_v3/ARCHIVE_MANIFEST.json`` (relative path and sha256 of every
archived file) and re-checks every digest after the move.

Usage (from anywhere):
    python archive_legacy.py [project_root]

``project_root`` defaults to the folder that holds this script.
This file is byte-identical in opus_health_dv_dbt and maximus_health_dv_dbt.

Requirements 1.1, 1.2, 1.3, 1.4.
"""
from __future__ import annotations

import hashlib
import json
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path

ARCHIVE_DIR = "legacy_v3"
MANIFEST_NAME = "ARCHIVE_MANIFEST.json"
ARCHIVED_FOLDERS = ("models", "generators")
PROTECTED = ("build_artifacts", "inputs", "build_profile.json")


class ArchiveError(Exception):
    """Base class for archive failures."""


class ArchiveExists(ArchiveError):
    """legacy_v3/ already exists; nothing was moved (Requirement 1.4)."""

    def __init__(self, path: Path):
        self.path = Path(path)
        super().__init__(f"Legacy archive already exists: {self.path}")


class ArchiveMismatch(ArchiveError):
    """Digests after the move differ from digests before the move."""

    def __init__(self, missing: list[str], changed: list[str], extra: list[str]):
        self.missing = missing
        self.changed = changed
        self.extra = extra
        lines = ["Archive digest check failed:"]
        lines += [f"  missing after move: {p}" for p in missing]
        lines += [f"  sha256 changed:     {p}" for p in changed]
        lines += [f"  unexpected file:    {p}" for p in extra]
        super().__init__("\n".join(lines))


@dataclass
class ArchiveResult:
    project_root: Path
    archive_root: Path
    manifest_path: Path
    files: dict[str, str] = field(default_factory=dict)  # rel path -> sha256
    counts: dict[str, int] = field(default_factory=dict)  # folder -> file count


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def _hash_tree(base: Path, folders: tuple[str, ...]) -> dict[str, str]:
    """Return {posix path relative to base: sha256} for every file under folders."""
    digests: dict[str, str] = {}
    for name in folders:
        root = base / name
        for dirpath, _dirnames, filenames in os.walk(root):
            for fn in filenames:
                full = Path(dirpath) / fn
                rel = full.relative_to(base).as_posix()
                digests[rel] = _sha256(full)
    return dict(sorted(digests.items()))


def archive(project_root: Path) -> ArchiveResult:
    """Move models/ and generators/ into legacy_v3/.

    Raises ArchiveExists(path) if legacy_v3/ exists (Requirement 1.4).
    Computes sha256 of every file before the move, moves with os.replace
    (same volume), recomputes after, and raises ArchiveMismatch on any
    difference. Never touches build_artifacts/, inputs/, build_profile.json.
    """
    project_root = Path(project_root).resolve()
    archive_root = project_root / ARCHIVE_DIR

    # Refuse before doing anything else.
    if os.path.lexists(archive_root):
        raise ArchiveExists(archive_root)

    missing_src = [n for n in ARCHIVED_FOLDERS if not (project_root / n).is_dir()]
    if missing_src:
        raise FileNotFoundError(
            "Expected folders not found under "
            f"{project_root}: {', '.join(missing_src)}"
        )

    protected_before = {p: (project_root / p).exists() for p in PROTECTED}

    before = _hash_tree(project_root, ARCHIVED_FOLDERS)

    archive_root.mkdir()
    for name in ARCHIVED_FOLDERS:
        os.replace(project_root / name, archive_root / name)

    counts = {
        name: sum(1 for p in before if p.startswith(name + "/"))
        for name in ARCHIVED_FOLDERS
    }
    manifest = {
        "archive_dir": ARCHIVE_DIR,
        "folders": list(ARCHIVED_FOLDERS),
        "file_counts": counts,
        "total_files": len(before),
        "files": [{"path": p, "sha256": d} for p, d in before.items()],
    }
    manifest_path = archive_root / MANIFEST_NAME
    with open(manifest_path, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(manifest, fh, indent=2)
        fh.write("\n")

    after = _hash_tree(archive_root, ARCHIVED_FOLDERS)
    missing = sorted(set(before) - set(after))
    extra = sorted(set(after) - set(before))
    changed = sorted(p for p in before.keys() & after.keys() if before[p] != after[p])
    if missing or changed or extra:
        raise ArchiveMismatch(missing, changed, extra)

    for p, existed in protected_before.items():
        if existed and not (project_root / p).exists():
            raise ArchiveError(f"Protected path disappeared: {project_root / p}")

    return ArchiveResult(
        project_root=project_root,
        archive_root=archive_root,
        manifest_path=manifest_path,
        files=before,
        counts=counts,
    )


def main(argv: list[str]) -> int:
    root = Path(argv[1]) if len(argv) > 1 else Path(__file__).resolve().parent
    try:
        result = archive(root)
    except ArchiveExists as exc:
        print(f"ERROR: {exc}. Nothing was moved.", file=sys.stderr)
        return 1
    except ArchiveMismatch as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2
    except (ArchiveError, FileNotFoundError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 3
    print(f"Archived into {result.archive_root}")
    for name, n in result.counts.items():
        print(f"  {name}/: {n} files")
    print(f"  total: {len(result.files)} files, all digests verified after move")
    print(f"Manifest: {result.manifest_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
