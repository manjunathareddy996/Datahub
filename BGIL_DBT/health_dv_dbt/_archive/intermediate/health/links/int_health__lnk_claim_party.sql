-- Intermediate harmonisation view for LNK_CLAIM_PARTY (Claim Party).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        reference_id as claim_bk,
        customer_id as party_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where reference_id is not null and customer_id is not null

    union all

    select distinct
        case_id as claim_bk,
        member_id as party_bk,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where case_id is not null and member_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        part_id as party_bk,
        'BJAZ_HM_BILL_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_payment') }}
    where claim_id is not null and part_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        hospital_id as party_bk,
        'BJAZ_HM_CASHLESS_INWARD' as record_source
    from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
    where claim_id is not null and hospital_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        member_id as party_bk,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where claim_id is not null and member_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        ldr_pid as party_bk,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where claim_id is not null and ldr_pid is not null

    union all

    select distinct
        clid as claim_bk,
        hospital_id as party_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where clid is not null and hospital_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        part_id as party_bk,
        'BJAZ_HM_INVESTI_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_investi_payment') }}
    where claim_id is not null and part_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        courier_id as party_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where claim_id is not null and courier_id is not null

    union all

    select distinct
        clid as claim_bk,
        hosp_id as party_bk,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where clid is not null and hosp_id is not null

    union all

    select distinct
        clid as claim_bk,
        hosp_id as party_bk,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where clid is not null and hosp_id is not null

    union all

    select distinct
        claim_no as claim_bk,
        payer_code as party_bk,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where claim_no is not null and payer_code is not null

    union all

    select distinct
        bjaz_claim_id as claim_bk,
        customer_id as party_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where bjaz_claim_id is not null and customer_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        hospital_id as party_bk,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where claim_id is not null and hospital_id is not null

)

select distinct claim_bk, party_bk, record_source
from unioned
