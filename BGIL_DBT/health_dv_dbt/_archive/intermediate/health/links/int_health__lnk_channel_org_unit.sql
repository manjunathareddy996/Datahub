-- Intermediate harmonisation view for LNK_CHANNEL_ORG_UNIT (Channel Managed By Org Unit).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        pd_partner_id as distribution_channel_bk,
        pd_location_code as org_unit_bk,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_partner_id is not null and pd_location_code is not null

    union all

    select distinct
        pd_partner_id as distribution_channel_bk,
        pd_location_code as org_unit_bk,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_partner_id is not null and pd_location_code is not null

    union all

    select distinct
        pd_partner_id as distribution_channel_bk,
        pd_location_code as org_unit_bk,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_partner_id is not null and pd_location_code is not null

    union all

    select distinct
        pd_partner_id as distribution_channel_bk,
        pd_location_code as org_unit_bk,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_partner_id is not null and pd_location_code is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        company_org_unit as org_unit_bk,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where partner_id is not null and company_org_unit is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        company_org_unit as org_unit_bk,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where imd_code is not null and company_org_unit is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        dept_code as org_unit_bk,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where partner_id is not null and dept_code is not null

    union all

    select distinct
        business_source as distribution_channel_bk,
        company_org_unit as org_unit_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where business_source is not null and company_org_unit is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        operating_office as org_unit_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where partner_id is not null and operating_office is not null

    union all

    select distinct
        business_source as distribution_channel_bk,
        company_org_unit as org_unit_bk,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where business_source is not null and company_org_unit is not null

    union all

    select distinct
        main_agent_code as distribution_channel_bk,
        company_org_unit as org_unit_bk,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where main_agent_code is not null and company_org_unit is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        branch_code as org_unit_bk,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where partner_id is not null and branch_code is not null

)

select distinct distribution_channel_bk, org_unit_bk, record_source
from unioned
