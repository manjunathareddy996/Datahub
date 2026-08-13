-- Intermediate harmonisation view for HUB_CLAIM.
-- Unions the HUB_CLAIM business key from every Health source table/column carrying it. (20 of 61 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_claim.sql.

with unioned as (

    select distinct
        reference_id as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where reference_id is not null

    union all

    -- DISCOVERED
    select distinct
        case_id as business_key,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where case_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where claim_id is not null

    union all

    select distinct
        case_id as business_key,
        'BJAZ_HAT_OCR_BILL_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_hat_ocr_bill_details') }}
    where case_id is not null

    union all

    select distinct
        case_id as business_key,
        'BJAZ_HAT_OCR_FINA_DTLS_LST' as record_source
    from {{ ref('stg_health__bjaz_hat_ocr_fina_dtls_lst') }}
    where case_id is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_BILL_CHARGE' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_charge') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_BILL_CHARGE' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_charge') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_BILL_DETAIL' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_detail') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_BILL_DETAIL' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_detail') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_BILL_DETAIL_OCR' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_BILL_DETAIL_OCR' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_BILL_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_payment') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_BILL_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_payment') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_CASHLESS_INWARD' as record_source
    from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where claim_id is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_DOCTOR_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_assess') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_DOCTOR_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_assess') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_DOCTOR_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_DOCTOR_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_DOC_RECOVERY' as record_source
    from {{ ref('stg_health__bjaz_hm_doc_recovery') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_DOC_RECOVERY' as record_source
    from {{ ref('stg_health__bjaz_hm_doc_recovery') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_EXCLUSION_APPLY' as record_source
    from {{ ref('stg_health__bjaz_hm_exclusion_apply') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_EXCLUSION_APPLY' as record_source
    from {{ ref('stg_health__bjaz_hm_exclusion_apply') }}
    where clid_hpms is not null

    union all

    select distinct
        clid as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where clid is not null

    union all

    select distinct
        claim_no as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where claim_no is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_INVESTI_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_investi_payment') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_INVESTI_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_investi_payment') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_INWARD_AUTOALLOCATION' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
    where claim_id is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_ORPHAN_REG' as record_source
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where claim_id is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_PCS_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_pcs_multi_assess') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_PCS_MULTI_ASSESS' as record_source
    from {{ ref('stg_health__bjaz_hm_pcs_multi_assess') }}
    where clid_hpms is not null

    union all

    select distinct
        clid as business_key,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where clid is not null

    union all

    select distinct
        clid as business_key,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where clid is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_PRO_ASSESSMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
    where claim_id is not null

    union all

    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_PRO_ASSESSMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
    where clid_hpms is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_HM_QUERY_REMARK' as record_source
    from {{ ref('stg_health__bjaz_hm_query_remark') }}
    where claim_id is not null

    union all

    select distinct
        claim_no as business_key,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where claim_no is not null

    union all

    select distinct
        claim_id as business_key,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where claim_id is not null

    union all

    select distinct
        bjaz_claim_id as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where bjaz_claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_CLM_WG_TRANS_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_CLM_WG_TRANS_DTLS_HIST' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_FPLM_OD_HOSPITAL_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_fplm_od_hospital_details') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        case_id as business_key,
        'BJAZ_HAT_DEDUTION_SUMMARY' as record_source
    from {{ ref('stg_health__bjaz_hat_dedution_summary') }}
    where case_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_HM_CLAIM_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_claim_payment') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_CLAIM_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_claim_payment') }}
    where clid_hpms is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_HM_CLM_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_enhance') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_CLM_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_enhance') }}
    where clid_hpms is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_HM_CLM_REGISTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register_extn') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        clid_hpms as business_key,
        'BJAZ_HM_CLM_REGISTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register_extn') }}
    where clid_hpms is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_INVESTIGATION_REPORTS' as record_source
    from {{ ref('stg_health__bjaz_investigation_reports') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_TPCLM_COURT_DTL_EXTN' as record_source
    from {{ ref('stg_health__bjaz_tpclm_court_dtl_extn') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_TPCLM_HOSPITAL_DTL' as record_source
    from {{ ref('stg_health__bjaz_tpclm_hospital_dtl') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_TPCLM_HOSPITAL_TRAN_DTL' as record_source
    from {{ ref('stg_health__bjaz_tpclm_hospital_tran_dtl') }}
    where claim_id is not null

    union all

    -- DISCOVERED
    select distinct
        claim_id as business_key,
        'BJAZ_WG_INSPECTION_DTLS' as record_source
    from {{ ref('stg_health__bjaz_wg_inspection_dtls') }}
    where claim_id is not null

)

select distinct business_key, record_source
from unioned
