-- Intermediate harmonisation view for LNK_PARTY_DOCUMENT (Party Document).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        medical_report as document_bk,
        member_no as party_bk,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where medical_report is not null and member_no is not null

    union all

    select distinct
        inward_id as document_bk,
        member_id as party_bk,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where inward_id is not null and member_id is not null

    union all

    select distinct
        inward_id as document_bk,
        courier_id as party_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where inward_id is not null and courier_id is not null

    union all

    select distinct
        omni_inward_no as document_bk,
        hosp_id as party_bk,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where omni_inward_no is not null and hosp_id is not null

    union all

    select distinct
        omni_inward_no as document_bk,
        hosp_id as party_bk,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where omni_inward_no is not null and hosp_id is not null

    union all

    select distinct
        medical_report as document_bk,
        member_no as party_bk,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where medical_report is not null and member_no is not null

    union all

    select distinct
        omni_inward_no as document_bk,
        payer_code as party_bk,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where omni_inward_no is not null and payer_code is not null

    union all

    select distinct
        medical_report as document_bk,
        member_no as party_bk,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where medical_report is not null and member_no is not null

    union all

    select distinct
        card_no as document_bk,
        hospital_id as party_bk,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where card_no is not null and hospital_id is not null

)

select distinct document_bk, party_bk, record_source
from unioned
