-- Intermediate harmonisation view for LNK_POLICY_LOCATION (Policy Risk Location).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        child_loc_code as location_bk,
        contract_id as policy_bk,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where child_loc_code is not null and contract_id is not null

    union all

    select distinct
        location_code as location_bk,
        policy_ref as policy_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where location_code is not null and policy_ref is not null

    union all

    select distinct
        risk_location as location_bk,
        policy_ref as policy_bk,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where risk_location is not null and policy_ref is not null

    union all

    select distinct
        locationcode as location_bk,
        pmasterpolicynumber as policy_bk,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where locationcode is not null and pmasterpolicynumber is not null

    union all

    select distinct
        policy_location as location_bk,
        policy as policy_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where policy_location is not null and policy is not null

    union all

    select distinct
        location_code as location_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where location_code is not null and policy_ref is not null

    union all

    select distinct
        orphan_loc as location_bk,
        policy_number as policy_bk,
        'BJAZ_HM_ORPHAN_REG' as record_source
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where orphan_loc is not null and policy_number is not null

    union all

    select distinct
        location_code as location_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where location_code is not null and policy_ref is not null

    union all

    select distinct
        location_code as location_bk,
        policy_ref as policy_bk,
        'BJAZ_CLM_WG_TRANS_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
    where location_code is not null and policy_ref is not null

    union all

    select distinct
        location_code as location_bk,
        policy_ref as policy_bk,
        'BJAZ_CLM_WG_TRANS_DTLS_HIST' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
    where location_code is not null and policy_ref is not null

    union all

    select distinct
        location_code as location_bk,
        policy_ref as policy_bk,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where location_code is not null and policy_ref is not null

    union all

    select distinct
        locationcode as location_bk,
        master_policy_no as policy_bk,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where locationcode is not null and master_policy_no is not null

    union all

    select distinct
        location_code as location_bk,
        contract_id as policy_bk,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where location_code is not null and contract_id is not null

)

select distinct location_bk, policy_bk, record_source
from unioned
