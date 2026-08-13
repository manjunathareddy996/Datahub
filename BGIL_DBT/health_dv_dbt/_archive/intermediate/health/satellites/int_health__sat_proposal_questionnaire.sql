-- Intermediate harmonisation view for SAT_PROPOSAL_QUESTIONNAIRE (HUB_PROPOSAL grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 1 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, question_code_ck, response_value, record_source
from (
    select distinct
        quote_ref_no as parent_bk,
        cast(null as varchar) as question_code_ck,
        nullif(trim(to_varchar(prev_disease_covered_yn)), '') as response_value,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where quote_ref_no is not null
    )
