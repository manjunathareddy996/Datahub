{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_CLAIM_EXCLUSION_APPLIED from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- 6 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'CONDITION' as EXCLUSION_SET_CODE,
        exclusion_detailcondition as EXCLUSION_DETAIL_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where exclusion_detailcondition is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'ETRAVEL' as EXCLUSION_SET_CODE,
        exclusion_detailetravel as EXCLUSION_DETAIL_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where exclusion_detailetravel is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'GROUP BUSINESS TRAVELLER INSURANCE' as EXCLUSION_SET_CODE,
        exclusion_detailgroup_business_traveler_insurance as EXCLUSION_DETAIL_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where exclusion_detailgroup_business_traveler_insurance is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'STANDARD TRAVEL POLICY EXCLUSIONS' as EXCLUSION_SET_CODE,
        exclusion_detailstandard_travel_policy_exclusions as EXCLUSION_DETAIL_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where exclusion_detailstandard_travel_policy_exclusions is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'STANDARD TRAVEL POLICY' as EXCLUSION_SET_CODE,
        exclusion_detailstandard_travel_policy as EXCLUSION_DETAIL_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where exclusion_detailstandard_travel_policy is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'STANDARD TRAVEL PRIME EXCLUSIONS' as EXCLUSION_SET_CODE,
        exclusion_detailstandard_travel_prime_exclusions as EXCLUSION_DETAIL_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where exclusion_detailstandard_travel_prime_exclusions is not null
