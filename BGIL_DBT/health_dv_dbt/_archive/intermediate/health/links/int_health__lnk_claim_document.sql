-- Intermediate harmonisation view for LNK_CLAIM_DOCUMENT (Claim Document).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        claim_id as claim_bk,
        inward_id as document_bk,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where claim_id is not null and inward_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        omni_inward_no as document_bk,
        'BJAZ_HM_INWARD_AUTOALLOCATION' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_autoallocation') }}
    where claim_id is not null and omni_inward_no is not null

    union all

    select distinct
        claim_id as claim_bk,
        inward_id as document_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where claim_id is not null and inward_id is not null

    union all

    select distinct
        claim_id as claim_bk,
        outward_id as document_bk,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where claim_id is not null and outward_id is not null

    union all

    select distinct
        clid as claim_bk,
        omni_inward_no as document_bk,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where clid is not null and omni_inward_no is not null

    union all

    select distinct
        clid as claim_bk,
        omni_inward_no as document_bk,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where clid is not null and omni_inward_no is not null

    union all

    select distinct
        claim_no as claim_bk,
        omni_inward_no as document_bk,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where claim_no is not null and omni_inward_no is not null

    union all

    select distinct
        claim_id as claim_bk,
        card_no as document_bk,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where claim_id is not null and card_no is not null

)

select distinct claim_bk, document_bk, record_source
from unioned
