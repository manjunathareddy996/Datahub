-- Intermediate harmonisation view for SAT_POLICY_CLAUSE_ATTACHED (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 1 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, clause_code_ck, clause_title, record_source
from (
    select distinct
        reg_no as parent_bk,
        cast(null as varchar) as clause_code_ck,
        nullif(trim(to_varchar(hpr_disclaimer1)), '') as clause_title,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where reg_no is not null
    )
