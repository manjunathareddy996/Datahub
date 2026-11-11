"""Property: Every ref() and stage source_model resolves; unresolved ones are reported.

For any synthetic project, the reference sweep reports exactly the ref() names
(including those in `-- depends_on:` comments) and stage source_model names that
have no model file under models/, and counts every ref() it checks.

**Validates: Requirements 8.2**
"""
import json
import shutil
import sys
import tempfile
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from check_health_project import Context, check_reference_sweep  # noqa: E402

REAL_ROOT = Path(__file__).resolve().parent.parent.parent
NAMES = st.text(alphabet="abcdefgh_", min_size=1, max_size=6).map(lambda s: "m_" + s)


@st.composite
def projects(draw):
    existing = draw(st.lists(NAMES, min_size=1, max_size=6, unique=True))
    pool = existing + draw(st.lists(NAMES, max_size=4))  # may include missing names
    refs = draw(st.lists(st.tuples(st.sampled_from(pool), st.booleans()), max_size=8))
    stage_targets = draw(st.lists(st.sampled_from(pool), max_size=4, unique=True))
    return existing, refs, stage_targets


@settings(max_examples=150, deadline=None)
@given(proj=projects())
def test_unresolved_refs_and_source_models_reported_exactly(proj):
    existing, refs, stage_targets = proj
    root = Path(tempfile.mkdtemp())
    try:
        models = root / "models" / "other"
        models.mkdir(parents=True)
        (root / "scripts").mkdir()
        for n in existing:
            (models / f"{n}.sql").write_text("select 1\n", encoding="utf-8")
        lines, expected = [], []
        for name, as_comment in refs:
            if as_comment:
                lines.append(f"-- depends_on: {{{{ ref('{name}') }}}}")
            else:
                lines.append(f"select * from {{{{ ref('{name}') }}}}")
            if name not in existing:
                expected.append((name, as_comment))
        (models / "consumer.sql").write_text("\n".join(lines) + "\n", encoding="utf-8")
        stg = root / "models" / "raw_vault" / "standard" / "staging"
        stg.mkdir(parents=True)
        for i, t in enumerate(stage_targets):
            (stg / f"stg_{i}.sql").write_text(f"-- source_model: {t}\nselect 1\n", encoding="utf-8")

        res = check_reference_sweep(Context(root, root))
        sweep = json.loads((root / "scripts" / "reference_sweep.json").read_text(encoding="utf-8"))

        got = sorted((u["ref"], u["in_depends_on_comment"]) for u in sweep["unresolved_refs"])
        assert got == sorted(expected)
        assert sweep["refs_checked"] == len(refs)
        assert sweep["refs_in_depends_on_comments"] == sum(1 for _, c in refs if c)
        assert sweep["source_model_checked"] == len(stage_targets)
        assert sorted(u["source_model"] for u in sweep["unresolved_source_models"]) == sorted(
            t for t in stage_targets if t not in existing)
        if expected or any(t not in existing for t in stage_targets):
            assert not res.ok
    finally:
        shutil.rmtree(root, ignore_errors=True)


def test_real_project_has_no_unresolved_references():
    res = check_reference_sweep(Context(REAL_ROOT, REAL_ROOT.parent / "opus_partner_dv_dbt"))
    sweep = json.loads((REAL_ROOT / "scripts" / "reference_sweep.json").read_text(encoding="utf-8"))
    assert sweep["unresolved_refs"] == []
    assert sweep["unresolved_source_models"] == []
    assert sweep["refs_checked"] > 0 and sweep["source_model_checked"] > 0, res.details
