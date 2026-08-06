-- Intermediate harmonisation view for LNK_PARTY_ORG_UNIT (Party Serviced By Org Unit).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        pd_location_code as org_unit_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_location_code is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_location_code as org_unit_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_location_code is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_location_code as org_unit_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_location_code is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_location_code as org_unit_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_location_code is not null and pd_premium_payer_id is not null

    union all

    select distinct
        company_org_unit as org_unit_bk,
        bagic_e_code as party_bk,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where company_org_unit is not null and bagic_e_code is not null

    union all

    select distinct
        company_org_unit as org_unit_bk,
        part_id as party_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where company_org_unit is not null and part_id is not null

    union all

    select distinct
        operating_office as org_unit_bk,
        customer_id as party_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where operating_office is not null and customer_id is not null

    union all

    select distinct
        company_org_unit as org_unit_bk,
        emp_code as party_bk,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where company_org_unit is not null and emp_code is not null

    union all

    select distinct
        company_org_unit as org_unit_bk,
        part_id as party_bk,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where company_org_unit is not null and part_id is not null

)

select distinct org_unit_bk, party_bk, record_source
from unioned
