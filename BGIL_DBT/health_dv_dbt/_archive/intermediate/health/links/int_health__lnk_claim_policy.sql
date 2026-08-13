-- Intermediate harmonisation view for LNK_CLAIM_POLICY (Claim Policy).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        reference_id as claim_bk,
        policy_ref as policy_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where reference_id is not null and policy_ref is not null

    union all

    select distinct
        case_id as claim_bk,
        policy_number as policy_bk,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where case_id is not null and policy_number is not null

    union all

    select distinct
        claim_id as claim_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_CASHLESS_INWARD' as record_source
    from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
    where claim_id is not null and policy_ref is not null

    union all

    select distinct
        claim_id as claim_bk,
        contract_id as policy_bk,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where claim_id is not null and contract_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where claim_id is not null and policy_ref is not null

    union all

    select distinct
        clid as claim_bk,
        policy as policy_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where clid is not null and policy is not null

    union all

    select distinct
        claim_id as claim_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where claim_id is not null and policy_ref is not null

    union all

    select distinct
        claim_id as claim_bk,
        policy_number as policy_bk,
        'BJAZ_HM_ORPHAN_REG' as record_source
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where claim_id is not null and policy_number is not null

    union all

    select distinct
        claim_id as claim_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where claim_id is not null and policy_ref is not null

    union all

    select distinct
        claim_no as claim_bk,
        policy_no as policy_bk,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where claim_no is not null and policy_no is not null

    union all

    select distinct
        bjaz_claim_id as claim_bk,
        policy_no as policy_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where bjaz_claim_id is not null and policy_no is not null

    union all

    select distinct
        claim_id as claim_bk,
        contract_id as policy_bk,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where claim_id is not null and contract_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        policy_ref as policy_bk,
        'BJAZ_CLM_WG_TRANS_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
    where claim_id is not null and policy_ref is not null

    union all

    select distinct
        claim_id as claim_bk,
        policy_ref as policy_bk,
        'BJAZ_CLM_WG_TRANS_DTLS_HIST' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
    where claim_id is not null and policy_ref is not null

)

select distinct claim_bk, policy_bk, record_source
from unioned
