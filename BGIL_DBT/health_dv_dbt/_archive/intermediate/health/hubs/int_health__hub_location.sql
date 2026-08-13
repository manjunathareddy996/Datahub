-- Intermediate harmonisation view for HUB_LOCATION.
-- Unions the HUB_LOCATION business key from every Health source table/column carrying it. (11 of 18 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_location.sql.

with unioned as (

    select distinct
        child_loc_code as business_key,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where child_loc_code is not null

    union all

    select distinct
        location_code as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where location_code is not null

    union all

    select distinct
        risk_location as business_key,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where risk_location is not null

    union all

    select distinct
        locationcode as business_key,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where locationcode is not null

    union all

    select distinct
        loc_code as business_key,
        'BJAZ_HM_CLAIM_STATUS_DASH_APP' as record_source
    from {{ ref('stg_health__bjaz_hm_claim_status_dash_app') }}
    where loc_code is not null

    union all

    -- CONFIRMED
    select distinct
        policy_location as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where policy_location is not null

    union all

    -- CONFIRMED
    select distinct
        pin_code as business_key,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where pin_code is not null

    union all

    select distinct
        location_code as business_key,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where location_code is not null

    union all

    select distinct
        orphan_loc as business_key,
        'BJAZ_HM_ORPHAN_REG' as record_source
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where orphan_loc is not null

    union all

    -- DISCOVERED
    select distinct
        location_code as business_key,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where location_code is not null

    union all

    -- DISCOVERED
    select distinct
        location_code as business_key,
        'BJAZ_CLM_SUPP_EXTN' as record_source
    from {{ ref('stg_health__bjaz_clm_supp_extn') }}
    where location_code is not null

    union all

    -- DISCOVERED
    select distinct
        loc_code as business_key,
        'BJAZ_CLM_SUPP_EXTN' as record_source
    from {{ ref('stg_health__bjaz_clm_supp_extn') }}
    where loc_code is not null

    union all

    -- DISCOVERED
    select distinct
        location_code as business_key,
        'BJAZ_CLM_WG_TRANS_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
    where location_code is not null

    union all

    -- DISCOVERED
    select distinct
        location_code as business_key,
        'BJAZ_CLM_WG_TRANS_DTLS_HIST' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
    where location_code is not null

    union all

    -- DISCOVERED
    select distinct
        location_code as business_key,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where location_code is not null

    union all

    -- DISCOVERED
    select distinct
        locationcode as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where locationcode is not null

    union all

    -- DISCOVERED
    select distinct
        location_code as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where location_code is not null

    union all

    -- DISCOVERED
    select distinct
        locationcode as business_key,
        'NG_HCM_INWARD_DETAILS' as record_source
    from {{ ref('stg_health__ng_hcm_inward_details') }}
    where locationcode is not null

)

select distinct business_key, record_source
from unioned
