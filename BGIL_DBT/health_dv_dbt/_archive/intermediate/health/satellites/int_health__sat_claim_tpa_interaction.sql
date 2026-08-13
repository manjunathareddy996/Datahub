-- Intermediate harmonisation view for SAT_CLAIM_TPA_INTERACTION (HUB_CLAIM grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 7 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, authorisation_message, authorisation_remarks, bill_submission_date, claimed_package_amount, denial_reason, enhancement_amount, enhancement_request_indicator, final_authorisation_amount, pre_auth_amount, pre_auth_approved_date, pre_auth_request_date, tpa_reference, record_source
from (
    with t0 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(enhancement_req_yn)), '') as enhancement_request_indicator,
            nullif(trim(to_varchar(pre_auth_date)), '') as pre_auth_request_date,
            nullif(trim(to_varchar(pre_auth_ref)), '') as tpa_reference
        from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by enhancement_request_indicator, pre_auth_request_date, tpa_reference) = 1
    ),
         t1 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(inward_remark)), '') as authorisation_remarks,
            nullif(trim(to_varchar(cashless_in_date)), '') as pre_auth_request_date
        from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by authorisation_remarks, pre_auth_request_date) = 1
    ),
         t2 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(enhance_auth_amt)), '') as enhancement_amount,
            nullif(trim(to_varchar(enhance_preauth_amt)), '') as pre_auth_amount,
            nullif(trim(to_varchar(enhance_date)), '') as pre_auth_approved_date
        from {{ ref('stg_health__bjaz_hm_clm_enhance') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by enhancement_amount, pre_auth_amount, pre_auth_approved_date) = 1
    ),
         t3 as (
        select distinct
            clid as parent_bk,
            nullif(trim(to_varchar(preauth_exclause)), '') as authorisation_message,
            nullif(trim(to_varchar(authorization_remarks)), '') as authorisation_remarks,
            nullif(trim(to_varchar(denial_reason)), '') as denial_reason,
            nullif(trim(to_varchar(auth_amount)), '') as final_authorisation_amount,
            nullif(trim(to_varchar(pre_auth_amt)), '') as pre_auth_amount,
            nullif(trim(to_varchar(auth_date)), '') as pre_auth_approved_date,
            nullif(trim(to_varchar(pre_auth_date)), '') as pre_auth_request_date
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where clid is not null
        qualify row_number() over (partition by parent_bk order by authorisation_message, authorisation_remarks, denial_reason, final_authorisation_amount, pre_auth_amount, pre_auth_approved_date, pre_auth_request_date) = 1
    ),
         t4 as (
        select distinct
            clid as parent_bk,
            nullif(trim(to_varchar(enhance_request)), '') as enhancement_amount,
            nullif(trim(to_varchar(trans_amount)), '') as final_authorisation_amount
        from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
        where clid is not null
        qualify row_number() over (partition by parent_bk order by enhancement_amount, final_authorisation_amount) = 1
    ),
         t5 as (
        select distinct
            claim_no as parent_bk,
            nullif(trim(to_varchar(payer_remarks)), '') as authorisation_remarks,
            nullif(trim(to_varchar(claimed_package_amount)), '') as claimed_package_amount,
            nullif(trim(to_varchar(approved_date)), '') as pre_auth_approved_date
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where claim_no is not null
        qualify row_number() over (partition by parent_bk order by authorisation_remarks, claimed_package_amount, pre_auth_approved_date) = 1
    ),
         t6 as (
        select distinct
            bjaz_claim_id as parent_bk,
            nullif(trim(to_varchar(date_of_doc_rec)), '') as bill_submission_date,
            nullif(trim(to_varchar(pre_auth_approved_on)), '') as pre_auth_approved_date,
            nullif(trim(to_varchar(pre_auth_received_on)), '') as pre_auth_request_date,
            nullif(trim(to_varchar(tpa_claim_no)), '') as tpa_reference
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where bjaz_claim_id is not null
        qualify row_number() over (partition by parent_bk order by bill_submission_date, pre_auth_approved_date, pre_auth_request_date, tpa_reference) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk) as parent_bk,
        coalesce(t3.authorisation_message) as authorisation_message,
        coalesce(t1.authorisation_remarks, t3.authorisation_remarks, t5.authorisation_remarks) as authorisation_remarks,
        coalesce(t6.bill_submission_date) as bill_submission_date,
        coalesce(t5.claimed_package_amount) as claimed_package_amount,
        coalesce(t3.denial_reason) as denial_reason,
        coalesce(t2.enhancement_amount, t4.enhancement_amount) as enhancement_amount,
        coalesce(t0.enhancement_request_indicator) as enhancement_request_indicator,
        coalesce(t3.final_authorisation_amount, t4.final_authorisation_amount) as final_authorisation_amount,
        coalesce(t2.pre_auth_amount, t3.pre_auth_amount) as pre_auth_amount,
        coalesce(t2.pre_auth_approved_date, t3.pre_auth_approved_date, t5.pre_auth_approved_date, t6.pre_auth_approved_date) as pre_auth_approved_date,
        coalesce(t0.pre_auth_request_date, t1.pre_auth_request_date, t3.pre_auth_request_date, t6.pre_auth_request_date) as pre_auth_request_date,
        coalesce(t0.tpa_reference, t6.tpa_reference) as tpa_reference,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_CLM_PRE_AUTH_HLT_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_HM_CASHLESS_INWARD' end, case when t2.parent_bk is not null then 'BJAZ_HM_CLM_ENHANCE' end, case when t3.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t4.parent_bk is not null then 'BJAZ_HM_PREAUTH_ENHANCE' end, case when t5.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end, case when t6.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    )
