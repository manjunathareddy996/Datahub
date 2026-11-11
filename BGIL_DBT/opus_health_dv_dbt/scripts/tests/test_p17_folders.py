"""Property: Missing configured folders are recorded.

For any set of folders named in dbt_project.yml model configuration and any
subset that does not exist under models, the checker reports exactly that subset.

(Numbered 17 in tasks.md; labelled "Property 20" in design.md.)

**Validates: Requirements 2.8**
"""
import shutil
import sys
import tempfile
from pathlib import Path

import yaml
from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from check_health_project import Context, check_configured_folders, configured_folders  # noqa: E402

PROJECT = "opus_health_dv_dbt"
names = st.text(alphabet="abcdefgh_", min_size=1, max_size=5)


def trees(depth=2):
    """Nested folder tree: dict name -> subtree (possibly empty)."""
    if depth == 0:
        return st.just({})
    return st.dictionaries(names, st.deferred(lambda: trees(depth - 1)), max_size=3)


def to_cfg(tree):
    # Folder nodes are dicts; add a '+' config key so every node is a real dict
    return {k: {"+materialized": "view", **to_cfg(v)} for k, v in tree.items()}


@settings(max_examples=150, deadline=None)
@given(tree=trees(), data=st.data())
def test_missing_configured_folders_reported_exactly(tree, data):
    cfg = {"name": PROJECT, "models": {PROJECT: {"+materialized": "view", **to_cfg(tree)}}}
    folders = configured_folders(cfg["models"], PROJECT)
    missing = set(data.draw(st.sets(st.sampled_from(folders))) if folders else set())

    root = Path(tempfile.mkdtemp())
    try:
        (root / "dbt_project.yml").write_text(yaml.safe_dump(cfg), encoding="utf-8")
        models = root / "models"
        models.mkdir()
        for f in folders:
            if f not in missing:
                (models / f).mkdir(parents=True, exist_ok=True)
        # a missing folder whose child exists would be created implicitly; recompute truth
        expected = {f for f in folders if not (models / f).is_dir()}
        res = check_configured_folders(Context(root, root))
    finally:
        shutil.rmtree(root, ignore_errors=True)

    assert res.ok
    assert set(res.data["configured"]) == set(folders)
    assert set(res.data["missing"]) == expected
    assert len(res.data["missing"]) == len(set(res.data["missing"]))
    assert {d[len("missing: models/"):] for d in res.details if d.startswith("missing: models/")} == expected
