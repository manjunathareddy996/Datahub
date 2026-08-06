-- Intermediate harmonisation view for HUB_ORG_UNIT.
-- Unions the HUB_ORG_UNIT business key from every Health source table/column carrying it. (9 of 21 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_org_unit.sql.

with unioned as (

    select distinct
        pd_location_code as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_location_code is not null

    union all

    select distinct
        pd_location_code as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_location_code is not null

    union all

    select distinct
        pd_location_code as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_location_code is not null

    union all

    select distinct
        pd_location_code as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_location_code is not null

    union all

    select distinct
        company_org_unit as business_key,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where company_org_unit is not null

    union all

    select distinct
        company_org_unit as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where company_org_unit is not null

    union all

    select distinct
        branch as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where branch is not null

    union all

    select distinct
        department as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where department is not null

    union all

    select distinct
        dept_code as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where dept_code is not null

    union all

    select distinct
        branch_code as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where branch_code is not null

    union all

    select distinct
        company_org_unit as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where company_org_unit is not null

    union all

    select distinct
        department_code as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where department_code is not null

    union all

    -- CONFIRMED
    select distinct
        operating_office as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where operating_office is not null

    union all

    -- CONFIRMED
    select distinct
        controlling_office as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where controlling_office is not null

    union all

    -- DISCOVERED
    select distinct
        company_org_unit as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where company_org_unit is not null

    union all

    -- DISCOVERED
    select distinct
        department_code as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where department_code is not null

    union all

    -- DISCOVERED
    select distinct
        dept_code as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where dept_code is not null

    union all

    -- DISCOVERED
    select distinct
        company_org_unit as business_key,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where company_org_unit is not null

    union all

    -- DISCOVERED
    select distinct
        department_code as business_key,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where department_code is not null

    union all

    -- DISCOVERED
    select distinct
        branch_code as business_key,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where branch_code is not null

    union all

    -- DISCOVERED
    select distinct
        department_code as business_key,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where department_code is not null

)

select distinct business_key, record_source
from unioned
