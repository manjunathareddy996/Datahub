-- Intermediate harmonisation view for HUB_DOCUMENT.
-- Unions the HUB_DOCUMENT business key from every Health source table/column carrying it. (5 of 14 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_document.sql.

with unioned as (

    select distinct
        card_no as business_key,
        'BJAZ_CARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_card_dtls') }}
    where card_no is not null

    union all

    select distinct
        medical_report as business_key,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where medical_report is not null

    union all

    -- DISCOVERED
    select distinct
        inward_id as business_key,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where inward_id is not null

    union all

    -- DISCOVERED
    select distinct
        omni_inward_no as business_key,
        'BJAZ_HM_INWARD_AUTOALLOCATION' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
    where omni_inward_no is not null

    union all

    select distinct
        inward_id as business_key,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where inward_id is not null

    union all

    select distinct
        outward_id as business_key,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where outward_id is not null

    union all

    -- DISCOVERED
    select distinct
        outward_id as business_key,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where outward_id is not null

    union all

    select distinct
        omni_inward_no as business_key,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where omni_inward_no is not null

    union all

    select distinct
        omni_inward_no as business_key,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where omni_inward_no is not null

    union all

    select distinct
        medical_report as business_key,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where medical_report is not null

    union all

    select distinct
        omni_inward_no as business_key,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where omni_inward_no is not null

    union all

    select distinct
        medical_report as business_key,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where medical_report is not null

    union all

    -- DISCOVERED
    select distinct
        card_no as business_key,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where card_no is not null

    union all

    -- DISCOVERED
    select distinct
        inward_id as business_key,
        'NG_HCM_INWARD_DETAILS' as record_source
    from {{ ref('stg_health__ng_hcm_inward_details') }}
    where inward_id is not null

)

select distinct business_key, record_source
from unioned
