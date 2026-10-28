{{ config(materialized='view') }}

-- UNPIVOT for SAT_QUOTE_RATING_INPUT from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 8 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by FACTOR_CODE.
-- The hash is taken once, downstream, by stg2_mtv2_up__uwr_qpd_polp_msp_imsd_inp_pv__sat_quote_rating_input.
--
-- Payload is null-padded to the SATELLITE's full payload (3 column(s)), not to this
-- feeder's columns, so every feeder of SAT_QUOTE_RATING_INPUT is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   loading_ace                              1 attribute(s)
--   loading_ace_for_main_sub_cover           1 attribute(s)
--   office_premium_per_mille_pa              1 attribute(s)
--   office_premium_per_mille_per_trip        1 attribute(s)
--   premium_rate                             1 attribute(s)
--   rate_per_trip_per_mille                  1 attribute(s)
--   rate_per_trip_per_mille_for_main_sub_cover 1 attribute(s)
--   slab                                     1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'LOADING_ACE' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        loading_ace as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where loading_ace is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'LOADING_ACE_FOR_MAIN_SUB_COVER' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        loading_ace_for_main_sub_cover as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where loading_ace_for_main_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'OFFICE_PREMIUM_PER_MILLE_PA' as FACTOR_CODE,
        office_premium_per_mille_pa as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where office_premium_per_mille_pa is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'OFFICE_PREMIUM_PER_MILLE_PER_TRIP' as FACTOR_CODE,
        office_premium_per_mille_per_trip as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where office_premium_per_mille_per_trip is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'PREMIUM_RATE' as FACTOR_CODE,
        premium_rate as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where premium_rate is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'RATE_PER_TRIP_PER_MILLE' as FACTOR_CODE,
        rate_per_trip_per_mille as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where rate_per_trip_per_mille is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'RATE_PER_TRIP_PER_MILLE_FOR_MAIN_SUB_COVER' as FACTOR_CODE,
        rate_per_trip_per_mille_for_main_sub_cover as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where rate_per_trip_per_mille_for_main_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'SLAB' as FACTOR_CODE,
        slab_ as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where slab_ is not null
