"""Feature: opus-health-dv-dbt-runnable, Property 15: Unchanged files stay byte-identical

For any file in generators/, build_artifacts/, or an out-of-scope layer model
(stage, hub_feeds, hubs, links, satellites, references), and for
macros/stitch_incremental.sql against the Partner copy, the content hash after
the feature equals the hash before it (or the Partner hash for the macro),
compared at the new path for moved files. Staging models differ from the
baseline only by the one inserted inc_job_updated_at line.

**Validates: Requirements 3.2, 4.13, 5.3, 5.5, 6.1, 6.2**
"""
import hashlib
import json
import re
from pathlib import Path

from hypothesis import given, settings, strategies as st

ROOT = Path(__file__).resolve().parent.parent.parent
PARTNER = ROOT.parent / "opus_partner_dv_dbt"
MANIFEST = json.loads((ROOT / "scripts" / "baseline_manifest.json").read_text(encoding="utf-8"))

OLD = "models/automate_dv/"
NEW = "models/raw_vault/"
INSERTED = re.compile(rb'^[ \t]*"INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,[ \t]*\r?\n', re.M)

# Intentionally edited / rewritten (tasks 11.1 and the stitch conversion)
EDITED = {"README.md", "docs/BUILDER_ASKS_HEALTH_V5.md"}
STITCHED = OLD + "standard/stitched/"


def current_path(p: str) -> str:
    return NEW + p[len(OLD):] if p.startswith(OLD) else p


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def category(p: str):
    """Return 'frozen', 'staging', or None (out of this property's scope)."""
    if p in EDITED or p.startswith(STITCHED):
        return None
    if p.startswith(("generators/", "build_artifacts/")):
        return "frozen"
    if p.startswith(OLD):
        return "frozen"  # hubs, links, satellites, references, stage models
    if p.startswith("models/staging/") and p.endswith(".sql"):
        return "staging"
    if p.startswith("models/staging/"):
        return "frozen"
    return None


def check(p: str):
    """Return an error string or None."""
    f = ROOT / current_path(p)
    if not f.is_file():
        return f"missing: {current_path(p)}"
    want = MANIFEST[p]
    if sha(f) == want:
        return None
    if category(p) == "staging":
        data = f.read_bytes()
        stripped, n = INSERTED.subn(b"", data)
        if n == 1 and hashlib.sha256(stripped).hexdigest() == want:
            return None
        return f"staging differs beyond inserted line (matches={n}): {p}"
    return f"changed: {p}"


CHECKED = sorted(p for p in MANIFEST if category(p))


def test_checked_set_nonempty():
    assert CHECKED
    assert any(c.startswith("generators/") for c in CHECKED)
    assert any(c.startswith("build_artifacts/") for c in CHECKED)
    assert any(category(c) == "staging" for c in CHECKED)


# Feature: opus-health-dv-dbt-runnable, Property 15: Unchanged files stay byte-identical
@settings(max_examples=100, deadline=None)
@given(st.sampled_from(CHECKED))
def test_sampled_files_unchanged(p):
    assert check(p) is None, check(p)


# Feature: opus-health-dv-dbt-runnable, Property 15: full-set check
def test_all_frozen_files_unchanged():
    errors = [e for e in (check(p) for p in CHECKED) if e]
    assert not errors, f"{len(errors)} unexpected: {errors[:20]}"


# Feature: opus-health-dv-dbt-runnable, Property 15: macro matches Partner copy
def test_stitch_macro_matches_partner():
    mine = ROOT / "macros" / "stitch_incremental.sql"
    theirs = PARTNER / "macros" / "stitch_incremental.sql"
    assert mine.read_bytes() == theirs.read_bytes()
