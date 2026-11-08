"""Unit tests for dvgen.render_ref (task 5.11; Requirement 6.10)."""
from __future__ import annotations

import pytest

from dvgen import emit, naming
from dvgen.model import Artifact
from dvgen.render_ref import RefRenderError, render_ref

PATH = "models/raw_vault/standard/references/ref_bank_branch_ifsc.sql"
A = "stg_health__bjaz_neft_ifsc_master"
B = "stg_health__bjaz_bank_branch"


def _src(model=A, table="BJAZ_NEFT_IFSC_MASTER", ldts="inc_job_updated_at",
         cols=(("IFSCCODE", "ifsc_code"), ("MICRCODE", "micr_code")), rs=None):
    return {"source_model": model, "table": table,
            "record_source": rs if rs is not None else naming.source_tag("OPUS_", table),
            "load_datetime": ldts,
            "columns": [{"column": c, "expr": e} for c, e in cols]}


def _art(sources=None, name="ref_bank_branch_ifsc", path=PATH, **over):
    data = {"ref": "REF_BANK_BRANCH_IFSC", "record_source_prefix": "OPUS_",
            "sources": sources if sources is not None else [_src()]}
    data.update(over)
    return Artifact(kind="ref", path=path, name=name, data=data)


def test_single_source_matches_design_shape():
    text = render_ref(_art())
    assert text == (
        "{{ config(materialized='view') }}\n"
        f"{emit.generated_header('render_ref')}\n"
        "-- HEALTH reference view for REF_BANK_BRANCH_IFSC: distinct payload rows "
        "from 1 Stg1 model(s).\n"
        "-- RECORD_SOURCE is the plain prefix + TABLE literal (no constant marker); "
        "LOAD_DATETIME is the table's watermark.\n"
        "select distinct\n"
        "    ifsc_code as IFSCCODE,\n"
        "    micr_code as MICRCODE,\n"
        "    'OPUS_BJAZ_NEFT_IFSC_MASTER' as RECORD_SOURCE,\n"
        "    inc_job_updated_at as LOAD_DATETIME\n"
        "from {{ ref('stg_health__bjaz_neft_ifsc_master') }}\n"
    )
    assert emit.has_generated_header(text)
    assert "\r" not in text and text.endswith("\n") and not text.endswith("\n\n")
    assert "'!" not in text


def test_watermark_override_flows_into_load_datetime():
    ldts = naming.watermark_for("BJAZ_NEFT_IFSC_MASTER", "inc_job_updated_at",
                                {"BJAZ_NEFT_IFSC_MASTER": "UPDATED_ON"})
    text = render_ref(_art([_src(ldts=ldts)]))
    assert "    updated_on as LOAD_DATETIME\n" in text


def test_two_sources_union_all_in_first_source_column_order():
    second = _src(model=B, table="BJAZ_BANK_BRANCH",
                  cols=(("MICRCODE", "micr"), ("IFSCCODE", "ifsc")))
    text = render_ref(_art([_src(), second]))
    assert text.count("select distinct") == 2
    assert text.count("union all\n") == 1
    tail = text.split("union all\n", 1)[1]
    assert tail.index("ifsc as IFSCCODE") < tail.index("micr as MICRCODE")
    assert "'OPUS_BJAZ_BANK_BRANCH' as RECORD_SOURCE" in tail
    assert tail.endswith(f"from {{{{ ref('{B}') }}}}\n")


def test_deterministic():
    assert render_ref(_art()) == render_ref(_art())


@pytest.mark.parametrize("art", [
    _art(name="ref_other"),
    _art(path="models/raw_vault/standard/references/ref_x.sql"),
    _art(sources=[]),
    _art(sources=[_src(rs="!OPUS_BJAZ_NEFT_IFSC_MASTER")]),
    _art(sources=[_src(rs="MAXIMUS_BJAZ_NEFT_IFSC_MASTER")]),
    _art(sources=[_src(cols=())]),
    _art(sources=[_src(cols=(("IFSCCODE", "a"), ("IFSCCODE", "b")))]),
    _art(sources=[_src(cols=(("RECORD_SOURCE", "a"),))]),
    _art(sources=[_src(cols=(("IFSCCODE", "a; drop table x"),))]),
    _art(sources=[_src(), _src()]),
    _art(sources=[_src(), _src(model=B, cols=(("IFSCCODE", "a"),))]),
])
def test_rejects_contract_violations(art):
    with pytest.raises(RefRenderError):
        render_ref(art)


def test_rejects_wrong_kind():
    art = Artifact(kind="sat", path=PATH, name="ref_bank_branch_ifsc",
                   data={"ref": "REF_BANK_BRANCH_IFSC", "sources": [_src()]})
    with pytest.raises(RefRenderError):
        render_ref(art)
