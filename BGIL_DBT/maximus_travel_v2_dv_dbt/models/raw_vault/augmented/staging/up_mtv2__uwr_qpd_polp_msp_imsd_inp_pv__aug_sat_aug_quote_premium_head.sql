{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_QUOTE_PREMIUM_HEAD from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
-- 5 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'GROSS' as PREMIUM_HEAD_CODE,
        cast(null as varchar) as BASE_AMOUNT,
        gross_premium as NET_HEAD_PREMIUM,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where gross_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ONE_WAY_FIXED' as PREMIUM_HEAD_CODE,
        fixed_one_way_premium as BASE_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where fixed_one_way_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ONE_WAY_TRIP' as PREMIUM_HEAD_CODE,
        cast(null as varchar) as BASE_AMOUNT,
        one_way_premium as NET_HEAD_PREMIUM,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where one_way_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ROUND_TRIP' as PREMIUM_HEAD_CODE,
        cast(null as varchar) as BASE_AMOUNT,
        round_trip_premium as NET_HEAD_PREMIUM,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where round_trip_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ROUND_TRIP_FIXED' as PREMIUM_HEAD_CODE,
        fixed_round_trip_premium as BASE_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where fixed_round_trip_premium is not null
