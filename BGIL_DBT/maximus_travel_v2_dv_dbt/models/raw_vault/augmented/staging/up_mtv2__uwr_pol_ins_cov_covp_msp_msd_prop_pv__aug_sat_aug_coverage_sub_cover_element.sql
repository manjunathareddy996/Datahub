{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_COVERAGE_SUB_COVER_ELEMENT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- 4 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(w0_cover_code),'')) is not null then 'COV:' || nullif(trim(w0_cover_code), '') end),'') as COVERAGE_BK,
        'AMBULANCE' as SUB_COVER_CODE,
        ambulance_sub_cover as SUB_COVER_APPLICABILITY,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv') }}
    where ambulance_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_cover_code),'')) is not null then 'COV:' || nullif(trim(w0_cover_code), '') end),'') as COVERAGE_BK,
        'TRAVEL_INCONVENIENCE' as SUB_COVER_CODE,
        inconvenience_sub_cover as SUB_COVER_APPLICABILITY,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv') }}
    where inconvenience_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_cover_code),'')) is not null then 'COV:' || nullif(trim(w0_cover_code), '') end),'') as COVERAGE_BK,
        'TRIP_CANCELLATION' as SUB_COVER_CODE,
        cancellation_sub_cover as SUB_COVER_APPLICABILITY,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv') }}
    where cancellation_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_cover_code),'')) is not null then 'COV:' || nullif(trim(w0_cover_code), '') end),'') as COVERAGE_BK,
        'TRIP_CANCELLATION_MAIN' as SUB_COVER_CODE,
        cancellation_main_sub_cover as SUB_COVER_APPLICABILITY,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv') }}
    where cancellation_main_sub_cover is not null
