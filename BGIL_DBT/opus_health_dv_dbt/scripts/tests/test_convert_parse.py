"""Unit tests for the stitch parser (task 7.1). Requirements 4.3, 4.4, 4.5, 4.13."""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import convert_stitches as c  # noqa: E402

SAMPLE = """-- CENTRAL VIEW v99_x
-- Tables merged, in source precedence:
--   T_ONE (a)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_POLICY_CLASSIFICATION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_PARTY
{{ config(materialized='view') }}

with merged as (

    -- branch 0: T_ONE
    select
        nullif(trim(a),'') as POLICY_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as number) as __LNK_POLICY_PARTY,
        'TX' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        v as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        7 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__t_one') }}
    where (a) is not null

    union all

    -- branch 1: T_TWO
    select
        a as POLICY_BK,
        p as PARTY_BK,
        1 as __LNK_POLICY_PARTY,
        kind as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__t_two') }}

)

select
    POLICY_BK,
    PARTY_BK,
    __LNK_POLICY_PARTY,
    POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    first_value(POLICY_CLASSIFICATION__CLASSIFICATION_VALUE) ignore nulls over (partition by POLICY_BK, POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE
from merged
"""


def test_parse_sample():
    p = c.parse(SAMPLE)
    assert p.fed_sats == ["SAT_POLICY_CLASSIFICATION"]
    assert p.fed_links == ["LNK_POLICY_PARTY"]
    assert [b.table for b in p.branches] == ["T_ONE", "T_TWO"]
    b0, b1 = p.branches
    assert b0.model == "stg_health__t_one" and b0.prec == 7 and b1.prec == 1001
    assert b0.keys == {"POLICY_BK": "nullif(trim(a),'')"}
    assert b0.where == "(a) is not null" and b1.where == ""
    assert b0.ck_literal == "TX" and not b0.ck_data_driven
    assert b1.ck_literal is None and b1.ck_data_driven
    assert b1.links == ["__LNK_POLICY_PARTY"] and b0.links == []
    assert set(b1.keys) == {"POLICY_BK", "PARTY_BK"}
    (sat,) = p.sats
    assert sat.sat == "POLICY_CLASSIFICATION"
    assert sat.payload == ["POLICY_CLASSIFICATION__CLASSIFICATION_VALUE"]
    assert sat.ck_columns == ["POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK"]
    assert c.stats(p)["link_leg_branches"] == 1


@pytest.mark.parametrize("bad", [
    SAMPLE.replace("with merged as (", "with other as ("),
    SAMPLE.replace("7 as __PREC", "x as __PREC"),
    SAMPLE.replace("from merged", ""),
])
def test_unparsable_raises(bad):
    with pytest.raises(c.ParseError):
        c.parse(bad)


def test_unparsable_is_reported_and_exit_nonzero(tmp_path):
    (tmp_path / "stitch_v01_bad.sql").write_text("select 1", encoding="utf-8")
    (tmp_path / "stitch_v02_ok.sql").write_text(SAMPLE, encoding="utf-8")
    report = tmp_path / "r.json"
    assert c.main(["--stitches-dir", str(tmp_path), "--report", str(report)]) == 1
    import json
    data = json.loads(report.read_text(encoding="utf-8"))
    assert data["findings"][0]["file"] == "stitch_v01_bad.sql"
    assert data["totals"]["stitches_parsed"] == 1


def test_all_originals_parse():
    from git_originals import ORIGINALS
    if len(ORIGINALS) != 34:
        pytest.skip("34 original stitches not available from git HEAD")
    for name, text in sorted(ORIGINALS.items()):
        c.parse(text, name)
