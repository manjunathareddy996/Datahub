{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_RISK_TRAVEL_RATING_INPUT from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- 12 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'ACE_PREMIUM_TYPE' as RATING_INPUT_CODE,
        cast(null as varchar) as PREMIUM_COMPONENT_AMOUNT,
        cast(null as varchar) as PREMIUM_RATE_VALUE,
        ace_premium_type as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where ace_premium_type is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'FIXED_ONE_WAY_PREMIUM' as RATING_INPUT_CODE,
        fixed_one_way_premium as PREMIUM_COMPONENT_AMOUNT,
        cast(null as varchar) as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where fixed_one_way_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'FIXED_ROUND_TRIP_PREMIUM' as RATING_INPUT_CODE,
        fixed_round_trip_premium as PREMIUM_COMPONENT_AMOUNT,
        cast(null as varchar) as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where fixed_round_trip_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'LOADING_ACE' as RATING_INPUT_CODE,
        loading_ace as PREMIUM_COMPONENT_AMOUNT,
        cast(null as varchar) as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where loading_ace is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'LOADING_ACE_FOR_MAIN_SUB_COVER' as RATING_INPUT_CODE,
        loading_ace_for_main_sub_cover as PREMIUM_COMPONENT_AMOUNT,
        cast(null as varchar) as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where loading_ace_for_main_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'OFFICE_PREMIUM_PER_MILLE_PA' as RATING_INPUT_CODE,
        cast(null as varchar) as PREMIUM_COMPONENT_AMOUNT,
        office_premium_per_mille_pa as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where office_premium_per_mille_pa is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'OFFICE_PREMIUM_PER_MILLE_PER_TRIP' as RATING_INPUT_CODE,
        cast(null as varchar) as PREMIUM_COMPONENT_AMOUNT,
        office_premium_per_mille_per_trip as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where office_premium_per_mille_per_trip is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'ONE_WAY_PREMIUM' as RATING_INPUT_CODE,
        one_way_premium as PREMIUM_COMPONENT_AMOUNT,
        cast(null as varchar) as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where one_way_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'PREMIUM_RATE' as RATING_INPUT_CODE,
        cast(null as varchar) as PREMIUM_COMPONENT_AMOUNT,
        premium_rate as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where premium_rate is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'RATE_PER_TRIP_PER_MILLE' as RATING_INPUT_CODE,
        cast(null as varchar) as PREMIUM_COMPONENT_AMOUNT,
        rate_per_trip_per_mille as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where rate_per_trip_per_mille is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'RATE_PER_TRIP_PER_MILLE_FOR_MAIN_SUB_COVER' as RATING_INPUT_CODE,
        cast(null as varchar) as PREMIUM_COMPONENT_AMOUNT,
        rate_per_trip_per_mille_for_main_sub_cover as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where rate_per_trip_per_mille_for_main_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'ROUND_TRIP_PREMIUM' as RATING_INPUT_CODE,
        round_trip_premium as PREMIUM_COMPONENT_AMOUNT,
        cast(null as varchar) as PREMIUM_RATE_VALUE,
        cast(null as varchar) as PREMIUM_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where round_trip_premium is not null
