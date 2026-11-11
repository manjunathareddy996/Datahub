"""Write a JSON manifest (relative posix path -> SHA-256) of the project folders.

Usage: python scripts/snapshot_manifest.py [output_path]
Default output: scripts/baseline_manifest.json (next to this script).
"""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FOLDERS = ("models", "generators", "build_artifacts", "docs")


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def build_manifest(root: Path = ROOT) -> dict:
    manifest = {}
    for folder in FOLDERS:
        base = root / folder
        if not base.is_dir():
            continue
        for p in sorted(base.rglob("*")):
            if p.is_file() and "__pycache__" not in p.parts:
                manifest[p.relative_to(root).as_posix()] = sha256(p)
    return manifest


def main() -> None:
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent / "baseline_manifest.json"
    manifest = build_manifest()
    out.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"{len(manifest)} entries written to {out}")


if __name__ == "__main__":
    main()
