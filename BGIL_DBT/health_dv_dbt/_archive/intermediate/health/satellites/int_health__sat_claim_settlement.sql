-- Intermediate harmonisation view for SAT_CLAIM_SETTLEMENT (HUB_CLAIM grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 4 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, approved_amount, settlement_amount, settlement_date, settlement_status, settlement_type, record_source
from (
    with t0 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(claim_passed)), '') as approved_amount,
            nullif(trim(to_varchar(paid_amount)), '') as settlement_amount
        from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by approved_amount, settlement_amount) = 1
    ),
         t1 as (
        select distinct
            clid as parent_bk,
            nullif(trim(to_varchar(approved_amt)), '') as approved_amount,
            nullif(trim(to_varchar(approval_date)), '') as settlement_date
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where clid is not null
        qualify row_number() over (partition by parent_bk order by approved_amount, settlement_date) = 1
    ),
         t2 as (
        select distinct
            claim_no as parent_bk,
            nullif(trim(to_varchar(total_approved_amount)), '') as approved_amount,
            nullif(trim(to_varchar(total_payable_amount)), '') as settlement_amount
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where claim_no is not null
        qualify row_number() over (partition by parent_bk order by approved_amount, settlement_amount) = 1
    ),
         t3 as (
        select distinct
            bjaz_claim_id as parent_bk,
            nullif(trim(to_varchar(approved_amount)), '') as approved_amount,
            nullif(trim(to_varchar(payble_amount)), '') as settlement_amount,
            nullif(trim(to_varchar(settelement_date)), '') as settlement_date,
            nullif(trim(to_varchar(status)), '') as settlement_status,
            nullif(trim(to_varchar(settelement_type)), '') as settlement_type
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where bjaz_claim_id is not null
        qualify row_number() over (partition by parent_bk order by approved_amount, settlement_amount, settlement_date, settlement_status, settlement_type) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t0.approved_amount, t1.approved_amount, t2.approved_amount, t3.approved_amount) as approved_amount,
        coalesce(t0.settlement_amount, t2.settlement_amount, t3.settlement_amount) as settlement_amount,
        coalesce(t1.settlement_date, t3.settlement_date) as settlement_date,
        coalesce(t3.settlement_status) as settlement_status,
        coalesce(t3.settlement_type) as settlement_type,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_COINSU_CLM_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t2.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end, case when t3.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )
