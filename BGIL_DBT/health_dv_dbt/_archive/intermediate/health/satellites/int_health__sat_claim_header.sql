-- Intermediate harmonisation view for SAT_CLAIM_HEADER (HUB_CLAIM grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 7 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, claim_category, claim_reference_number, claim_remarks, claim_status, claim_sub_status, claim_type, closed_date, gross_incurred_amount, net_incurred_amount, notification_date, registration_date, record_source
from (
    with t0 as (
        select distinct
            case_id as parent_bk,
            nullif(trim(to_varchar(inward_no)), '') as claim_reference_number
        from {{ ref('stg_health__bjaz_hat_ocr_fina_dtls_lst') }}
        where case_id is not null
        qualify row_number() over (partition by parent_bk order by claim_reference_number) = 1
    ),
         t1 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(claim_ref)), '') as claim_reference_number,
            nullif(trim(to_varchar(status)), '') as claim_status,
            nullif(trim(to_varchar(rfa_status)), '') as claim_sub_status,
            nullif(trim(to_varchar(type_of_claim)), '') as claim_type,
            nullif(trim(to_varchar(amt_of_claim_lodged)), '') as gross_incurred_amount,
            nullif(trim(to_varchar(total_amount)), '') as net_incurred_amount,
            nullif(trim(to_varchar(claim_date)), '') as notification_date,
            nullif(trim(to_varchar(date_of_cl_lodged)), '') as registration_date
        from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by claim_reference_number, claim_status, claim_sub_status, claim_type, gross_incurred_amount, net_incurred_amount, notification_date, registration_date) = 1
    ),
         t2 as (
        select distinct
            clid as parent_bk,
            nullif(trim(to_varchar(general_remarks)), '') as claim_remarks,
            nullif(trim(to_varchar(claim_status)), '') as claim_status,
            nullif(trim(to_varchar(claim_close_status)), '') as claim_sub_status,
            nullif(trim(to_varchar(claim_type)), '') as claim_type,
            nullif(trim(to_varchar(close_date)), '') as closed_date,
            nullif(trim(to_varchar(registration_date)), '') as registration_date
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where clid is not null
        qualify row_number() over (partition by parent_bk order by claim_remarks, claim_status, claim_sub_status, claim_type, closed_date, registration_date) = 1
    ),
         t3 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(orphan_remark)), '') as claim_remarks,
            nullif(trim(to_varchar(claim_type)), '') as claim_type,
            nullif(trim(to_varchar(orphan_inti_date)), '') as notification_date,
            nullif(trim(to_varchar(orphan_date)), '') as registration_date
        from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by claim_remarks, claim_type, notification_date, registration_date) = 1
    ),
         t4 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(closer_letdate)), '') as closed_date
        from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by closed_date) = 1
    ),
         t5 as (
        select distinct
            claim_no as parent_bk,
            nullif(trim(to_varchar(payer_reference_no)), '') as claim_reference_number,
            nullif(trim(to_varchar(claim_status)), '') as claim_status,
            nullif(trim(to_varchar(action_status)), '') as claim_sub_status,
            nullif(trim(to_varchar(claim_type)), '') as claim_type
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where claim_no is not null
        qualify row_number() over (partition by parent_bk order by claim_reference_number, claim_status, claim_sub_status, claim_type) = 1
    ),
         t6 as (
        select distinct
            bjaz_claim_id as parent_bk,
            nullif(trim(to_varchar(claim_category)), '') as claim_category,
            nullif(trim(to_varchar(bjaz_claim_status)), '') as claim_status,
            nullif(trim(to_varchar(claim_type)), '') as claim_type,
            nullif(trim(to_varchar(intimation_date)), '') as notification_date
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where bjaz_claim_id is not null
        qualify row_number() over (partition by parent_bk order by claim_category, claim_status, claim_type, notification_date) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk) as parent_bk,
        coalesce(t6.claim_category) as claim_category,
        coalesce(t0.claim_reference_number, t1.claim_reference_number, t5.claim_reference_number) as claim_reference_number,
        coalesce(t2.claim_remarks, t3.claim_remarks) as claim_remarks,
        coalesce(t1.claim_status, t2.claim_status, t5.claim_status, t6.claim_status) as claim_status,
        coalesce(t1.claim_sub_status, t2.claim_sub_status, t5.claim_sub_status) as claim_sub_status,
        coalesce(t1.claim_type, t2.claim_type, t3.claim_type, t5.claim_type, t6.claim_type) as claim_type,
        coalesce(t2.closed_date, t4.closed_date) as closed_date,
        coalesce(t1.gross_incurred_amount) as gross_incurred_amount,
        coalesce(t1.net_incurred_amount) as net_incurred_amount,
        coalesce(t1.notification_date, t3.notification_date, t6.notification_date) as notification_date,
        coalesce(t1.registration_date, t2.registration_date, t3.registration_date) as registration_date,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HAT_OCR_FINA_DTLS_LST' end, case when t1.parent_bk is not null then 'BJAZ_HM_COINSU_CLM_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t3.parent_bk is not null then 'BJAZ_HM_ORPHAN_REG' end, case when t4.parent_bk is not null then 'BJAZ_HM_PRO_ASSESSMENT' end, case when t5.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end, case when t6.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    )
