{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_RISK_TRAVEL_COVER_TERMS from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- 6 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'ACE' as SUB_COVER_CODE,
        ace_duration as ACE_COVER_DURATION,
        coalesce(sum_insured_ace, sum_insuredace) as ACE_SUM_INSURED,
        cast(null as varchar) as SUB_COVER_SUM_INSURED,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where ace_duration is not null or sum_insured_ace is not null or sum_insuredace is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'AMBULANCE' as SUB_COVER_CODE,
        cast(null as varchar) as ACE_COVER_DURATION,
        cast(null as varchar) as ACE_SUM_INSURED,
        ambulance_sub_cover as SUB_COVER_SUM_INSURED,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where ambulance_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'STANDARD_FIRE_AND_SPECIAL_PERILS' as SUB_COVER_CODE,
        cast(null as varchar) as ACE_COVER_DURATION,
        cast(null as varchar) as ACE_SUM_INSURED,
        standard_fire_and_special_perils_sub_cover as SUB_COVER_SUM_INSURED,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where standard_fire_and_special_perils_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'TRAVEL_INCONVENIENCE' as SUB_COVER_CODE,
        cast(null as varchar) as ACE_COVER_DURATION,
        cast(null as varchar) as ACE_SUM_INSURED,
        inconvenience_sub_cover as SUB_COVER_SUM_INSURED,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where inconvenience_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'TRIP_CANCELLATION' as SUB_COVER_CODE,
        cast(null as varchar) as ACE_COVER_DURATION,
        cast(null as varchar) as ACE_SUM_INSURED,
        cancellation_sub_cover as SUB_COVER_SUM_INSURED,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where cancellation_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'') as RISK_OBJECT_BK,
        'TRIP_CANCELLATION_MAIN' as SUB_COVER_CODE,
        cast(null as varchar) as ACE_COVER_DURATION,
        cast(null as varchar) as ACE_SUM_INSURED,
        cancellation_main_sub_cover as SUB_COVER_SUM_INSURED,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where cancellation_main_sub_cover is not null
