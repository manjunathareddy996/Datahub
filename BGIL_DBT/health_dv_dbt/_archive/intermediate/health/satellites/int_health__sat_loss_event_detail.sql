-- Intermediate harmonisation view for SAT_LOSS_EVENT_DETAIL (HUB_LOSS_EVENT grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 3 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, loss_date, loss_event_type, record_source
from (
    with t0 as (
        select distinct
            claim_no as parent_bk,
            nullif(trim(to_varchar(type_of_loss)), '') as loss_event_type
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where claim_no is not null
        qualify row_number() over (partition by parent_bk order by loss_event_type) = 1
    ),
         t1 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(type_of_loss)), '') as loss_event_type
        from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by loss_event_type) = 1
    ),
         t2 as (
        select distinct
            tpa_claim_no as parent_bk,
            nullif(trim(to_varchar(loss_date)), '') as loss_date
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where tpa_claim_no is not null
        qualify row_number() over (partition by parent_bk order by loss_date) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk) as parent_bk,
        coalesce(t2.loss_date) as loss_date,
        coalesce(t0.loss_event_type, t1.loss_event_type) as loss_event_type,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t1.parent_bk is not null then 'BJAZ_HM_INWARD_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    )
