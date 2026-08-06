-- Intermediate harmonisation view for LNK_ASSESSMENT_PARTY (Assessment Party).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        scrutiny_no as assessment_bk,
        alloted_to as party_bk,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where scrutiny_no is not null and alloted_to is not null

    union all

    select distinct
        pd_scrutiny_number as assessment_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_scrutiny_number is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_scrutiny_number as assessment_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_scrutiny_number is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_scrutiny_number as assessment_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_scrutiny_number is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_scrutiny_number as assessment_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_scrutiny_number is not null and pd_premium_payer_id is not null

    union all

    select distinct
        scrutiny_no as assessment_bk,
        customer_id as party_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where scrutiny_no is not null and customer_id is not null

    union all

    select distinct
        scrutiny_no as assessment_bk,
        bagic_e_code as party_bk,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where scrutiny_no is not null and bagic_e_code is not null

    union all

    select distinct
        scrutiny_no as assessment_bk,
        member_identifier as party_bk,
        'BJAZ_SCR_HLTH_PORTABLE_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where scrutiny_no is not null and member_identifier is not null

    union all

    select distinct
        scrutiny_no as assessment_bk,
        prospect_id as party_bk,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where scrutiny_no is not null and prospect_id is not null

    union all

    select distinct
        scrutiny_no as assessment_bk,
        customer_id as party_bk,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where scrutiny_no is not null and customer_id is not null

)

select distinct assessment_bk, party_bk, record_source
from unioned
