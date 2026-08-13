-- Intermediate harmonisation view for SAT_CLAIM_REPUDIATION (HUB_CLAIM grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 3 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, repudiation_date, repudiation_reason, record_source
from (
    with t0 as (
        select distinct
            clid as parent_bk,
            nullif(trim(to_varchar(repudiation_dt)), '') as repudiation_date,
            nullif(trim(to_varchar(repudiation_reason)), '') as repudiation_reason
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where clid is not null
        qualify row_number() over (partition by parent_bk order by repudiation_date, repudiation_reason) = 1
    ),
         t1 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(repudi_date)), '') as repudiation_date,
            nullif(trim(to_varchar(repudi_remark)), '') as repudiation_reason
        from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by repudiation_date, repudiation_reason) = 1
    ),
         t2 as (
        select distinct
            bjaz_claim_id as parent_bk,
            nullif(trim(to_varchar(rejection_reason)), '') as repudiation_reason
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where bjaz_claim_id is not null
        qualify row_number() over (partition by parent_bk order by repudiation_reason) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk) as parent_bk,
        coalesce(t0.repudiation_date, t1.repudiation_date) as repudiation_date,
        coalesce(t0.repudiation_reason, t1.repudiation_reason, t2.repudiation_reason) as repudiation_reason,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t1.parent_bk is not null then 'BJAZ_HM_PRO_ASSESSMENT' end, case when t2.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    )
