-- Intermediate harmonisation view for LNK_ORG_UNIT_HIERARCHY (Org Unit Hierarchy).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        branch as org_unit_from_bk,
        department as org_unit_to_bk,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where branch is not null and department is not null

    union all

    select distinct
        dept_code as org_unit_from_bk,
        branch_code as org_unit_to_bk,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where dept_code is not null and branch_code is not null

    union all

    select distinct
        company_org_unit as org_unit_from_bk,
        department_code as org_unit_to_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where company_org_unit is not null and department_code is not null

    union all

    select distinct
        operating_office as org_unit_from_bk,
        controlling_office as org_unit_to_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where operating_office is not null and controlling_office is not null

    union all

    select distinct
        company_org_unit as org_unit_from_bk,
        department_code as org_unit_to_bk,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where company_org_unit is not null and department_code is not null

    union all

    select distinct
        company_org_unit as org_unit_from_bk,
        department_code as org_unit_to_bk,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where company_org_unit is not null and department_code is not null

    union all

    select distinct
        branch_code as org_unit_from_bk,
        department_code as org_unit_to_bk,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where branch_code is not null and department_code is not null

)

select distinct org_unit_from_bk, org_unit_to_bk, record_source
from unioned
