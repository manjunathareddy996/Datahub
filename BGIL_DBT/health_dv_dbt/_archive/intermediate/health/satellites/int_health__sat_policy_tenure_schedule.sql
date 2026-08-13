-- Intermediate harmonisation view for SAT_POLICY_TENURE_SCHEDULE (HUB_POLICY grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 1 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, tenure_sequence_ck, tenure_premium, record_source
from (
    select distinct
        policy_ref as parent_bk,
        cast(null as varchar) as tenure_sequence_ck,
        nullif(trim(to_varchar(gross_premium1)), '') as tenure_premium,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where policy_ref is not null
    )
