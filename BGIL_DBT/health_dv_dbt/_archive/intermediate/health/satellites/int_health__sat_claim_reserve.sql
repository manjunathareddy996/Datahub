-- Intermediate harmonisation view for SAT_CLAIM_RESERVE (HUB_CLAIM grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 1 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select parent_bk, reserve_head_ck, current_reserve_amount, record_source
from (
    select distinct
        clid as parent_bk,
        cast(null as varchar) as reserve_head_ck,
        nullif(trim(to_varchar(reserve_amt)), '') as current_reserve_amount,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where clid is not null
    )
