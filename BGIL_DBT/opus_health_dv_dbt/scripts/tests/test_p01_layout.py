"""Feature: opus-health-dv-dbt-runnable, Property 1: Layout move preserves every model

For any set of model file paths under models/automate_dv in the pre-move
manifest, replacing the prefix with models/raw_vault gives a path set of the
same size (injective), every mapped path exists after the move, and no path
under models/automate_dv exists.

**Validates: Requirements 1.2, 1.3**
"""
import json
from pathlib import Path

from hypothesis import given, settings, strategies as st

ROOT = Path(__file__).resolve().parent.parent.parent
MANIFEST = json.loads((ROOT / "scripts" / "baseline_manifest.json").read_text(encoding="utf-8"))
OLD = "models/automate_dv/"
NEW = "models/raw_vault/"
OLD_PATHS = sorted(p for p in MANIFEST if p.startswith(OLD))


def remap(path: str) -> str:
    return NEW + path[len(OLD):]


def test_baseline_has_models():
    assert OLD_PATHS, "baseline manifest lists no models under models/automate_dv"


# Feature: opus-health-dv-dbt-runnable, Property 1: Layout move preserves every model
@settings(max_examples=100, deadline=None)
@given(st.lists(st.sampled_from(OLD_PATHS), min_size=1, max_size=len(OLD_PATHS), unique=True))
def test_layout_move_preserves_every_model(subset):
    mapped = [remap(p) for p in subset]
    # injective: same size after mapping
    assert len(set(mapped)) == len(subset)
    # every mapped path exists after the move
    for m in mapped:
        assert (ROOT / m).is_file(), f"missing after move: {m}"
    # nothing remains under the old prefix
    assert not (ROOT / "models" / "automate_dv").exists()


# Feature: opus-health-dv-dbt-runnable, Property 1: full-set check (all baseline paths)
def test_all_baseline_models_moved():
    mapped = {remap(p) for p in OLD_PATHS}
    assert len(mapped) == len(OLD_PATHS)
    missing = [m for m in mapped if not (ROOT / m).is_file()]
    assert not missing, missing[:5]
    assert not (ROOT / "models" / "automate_dv").exists()
