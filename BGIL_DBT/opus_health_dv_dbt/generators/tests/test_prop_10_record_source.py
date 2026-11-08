"""Property test for the record-source prefix in rendered models.

Feature: health-lob-dv-dbt-build, Property 10: Record-source prefix consistency

For any project prefix and table name, every stage ``RECORD_SOURCE`` equals
``'!' + prefix + TABLE``, every stitch ``source_tag`` equals
``prefix + TABLE``, and every ``src_record_source_map`` value equals the
project group, which is the prefix without its trailing underscore.

The checks read the rendered file text (the literals dbt will see), for both
Health_Projects: ``OPUS_`` / ``OPUS`` and ``MAXIMUS_`` / ``MAXIMUS``.

**Validates: Requirements 5.5, 5.6, 5.7, 7.3**
"""
from __future__ import annotations

import re
import string

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen import naming
from dvgen.model import Artifact
from dvgen.render_stage import render_stage
from dvgen.render_stitch import render_stitch
from dvgen.render_vault import render_sat

# Record_Source_Prefix -> project group (design project_config).
PROJECTS = {"OPUS_": "OPUS", "MAXIMUS_": "MAXIMUS"}

_PREFIX = st.sampled_from(sorted(PROJECTS))
# Physical table names: start with a letter so the stg1 model name is valid.
_TABLE = st.from_regex(r"[A-Z][A-Z0-9_]{0,24}", fullmatch=True)
_TABLES = st.lists(_TABLE, min_size=1, max_size=5, unique=True)
_LDTS = st.sampled_from(["INC_JOB_UPDATED_AT", "rec_refresh_at", "UPDATED_ON"])

_RS_LINE = re.compile(r"^  RECORD_SOURCE: '([^']*)'$", re.M)
_TAG_LINE = re.compile(r"'source_tag': '([^']*)'")


def _group(prefix: str) -> str:
    assert prefix.endswith("_")
    return prefix[:-1]


def _stage_artifact(kind: str, prefix: str, table: str, ldts: str) -> Artifact:
    stem = table.lower()
    data = {
        "target": "HUB_CLAIM",
        "source_model": naming.stg1_model(stem),
        "table": table,
        "record_source": naming.record_source(prefix, table),
        "load_datetime": ldts,
    }
    if kind == "stage_hub":
        data.update(parent_code="HUB_CLAIM", parent_bk="claim_id")
    elif kind == "stage_link":
        data.update(target="LNK_CLAIM_PARTY", parent_code="LNK_CLAIM_PARTY",
                    hub_keys=[{"code": "HUB_PARTY", "raw": "part_id"},
                              {"code": "HUB_CLAIM", "raw": "claim_id"}])
    else:
        data.update(target="SAT_CLAIM_NOTE", parent_code="HUB_CLAIM",
                    parent_bk="claim_id",
                    payload=[{"column": "NOTETEXT", "expr": "note_text"}])
    return Artifact(kind=kind, path=f"models/x/{stem}.sql",
                    name=f"stg2_x_{stem}", data=data)


@settings(max_examples=200)
@given(prefix=_PREFIX, table=_TABLE, ldts=_LDTS,
       kind=st.sampled_from(["stage_hub", "stage_link", "stage_sat",
                             "stage_aug"]))
def test_stage_record_source_is_bang_prefix_table(prefix, table, ldts, kind):
    text = render_stage(_stage_artifact(kind, prefix, table, ldts))
    literals = _RS_LINE.findall(text)
    assert literals == [f"!{prefix}{table.upper()}"]
    for lit in literals:
        assert lit.startswith("!" + prefix)
        # The other project's prefix never appears.
        for other in PROJECTS:
            if other != prefix:
                assert not lit.startswith("!" + other)


@settings(max_examples=200)
@given(prefix=_PREFIX, tables=_TABLES, ldts=_LDTS,
       with_prefix=st.booleans())
def test_stitch_source_tags_are_prefix_table(prefix, tables, ldts, with_prefix):
    sat = "SAT_POLICY_BONUS_TRACKING"
    models = [naming.stg1_model(t.lower()) for t in tables]
    data = {
        "sat": sat,
        "parent_code": "HUB_POLICY",
        "target_sat": "sat_policy_bonus_tracking",
        "unique_key": "parent_bk",
        "sources": [
            {"model": m, "source_tag": naming.source_tag(prefix, t),
             "ldts_column": ldts, "key_column": "contract_id",
             "columns": [{"src": "bonus_si", "tgt": "bonusamount"}]}
            for m, t in zip(models, tables)
        ],
        "output_columns": ["bonusamount"],
        "coalesce_rules": {"bonusamount": models},
    }
    if with_prefix:
        data["record_source_prefix"] = prefix
    name = naming.stitch_model(sat)
    text = render_stitch(Artifact(kind="stitch", path=f"models/x/{name}.sql",
                                  name=name, data=data))
    tags = _TAG_LINE.findall(text)
    assert tags == [f"{prefix}{t.upper()}" for t in tables]
    group = _group(prefix)
    for tag in tags:
        assert tag.startswith(prefix)
        assert tag.split("_", 1)[0] == group


def _record_source_map_values(text: str) -> dict[str, str]:
    lines = text.split("\n")
    start = lines.index("src_record_source_map:")
    out = {}
    for line in lines[start + 1:]:
        m = re.fullmatch(r"  ([A-Za-z_][A-Za-z0-9_]*): '([^']*)'", line)
        if not m:
            break
        out[m.group(1)] = m.group(2)
    return out


@settings(max_examples=200)
@given(prefix=_PREFIX,
       tables=st.lists(_TABLE, min_size=2, max_size=5, unique=True),
       multi_active=st.booleans())
def test_multi_source_record_source_map_is_group(prefix, tables, multi_active):
    group = _group(prefix)
    models = [naming.stg2_model("sat", t.lower(), "SAT_CLAIM_NOTE")
              for t in tables]
    data = {
        "satellite": "SAT_CLAIM_NOTE",
        "parent": "HUB_CLAIM",
        "macro": "ma_sat_multi_source" if multi_active else "sat_multi_source",
        "src_pk": "CLAIM_HKEY",
        "src_cdk": ["NOTESEQ"] if multi_active else [],
        "src_payload": ["NOTETEXT"],
        "source_model": models,
        "src_column_map": {m: ["NOTETEXT"] for m in models},
        "src_record_source_map": {m: group for m in models},
    }
    text = render_sat(Artifact(kind="sat", path="models/x/sat_claim_note.sql",
                               name="sat_claim_note", data=data))
    rs_map = _record_source_map_values(text)
    assert set(rs_map) == set(models)
    assert set(rs_map.values()) == {group}
    # The group is the prefix without its trailing underscore, so a
    # STARTSWITH(record_source, group || '_') filter matches every stage
    # RECORD_SOURCE of this project once the leading '!' is dropped.
    for table in tables:
        assert naming.record_source(prefix, table)[1:].startswith(group + "_")
