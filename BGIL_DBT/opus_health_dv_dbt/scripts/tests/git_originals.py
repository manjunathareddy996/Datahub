"""Load the ORIGINAL stitch_v*.sql files from git HEAD (the working tree holds consumer views)."""
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
_NAME = re.compile(r"stitch_v\d\d_.*\.sql$")


def _git(*args: str) -> bytes | None:
    try:
        p = subprocess.run(["git", *args], cwd=ROOT, capture_output=True, timeout=60)
    except (OSError, subprocess.TimeoutExpired):
        return None
    return p.stdout if p.returncode == 0 else None


def load_originals() -> dict[str, str]:
    """{file name: original text} for stitches whose HEAD version is still the original
    (contains 'with merged'). Empty if git or the originals are unavailable."""
    out: dict[str, str] = {}
    for layout in ("automate_dv", "raw_vault"):
        listing = _git("ls-tree", "--name-only", "HEAD", f"./models/{layout}/standard/stitched/")
        if not listing:
            continue
        for line in listing.decode("utf-8").splitlines():
            name = line.strip().rsplit("/", 1)[-1]
            if not _NAME.match(name) or name in out:
                continue
            blob = _git("show", f"HEAD:./models/{layout}/standard/stitched/{name}")
            if blob and b"with merged" in blob.lower().replace(b"\r", b""):
                out[name] = blob.decode("utf-8")
    return out


ORIGINALS = load_originals()
