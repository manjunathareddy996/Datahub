{{ config(materialized='view') }}

-- UNPIVOT for SAT_POLICY_PREMIUM_HEAD from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 7 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by ADJUSTED_INDICATOR, COVERAGE_REFERENCE, PREMIUM_HEAD_CODE, SECTION.
-- The hash is taken once, downstream, by stg2_mtv2_up__uwr_pol_polp_msp_msd_prop_pv__sat_policy_premium_head.
--
-- Payload is null-padded to the SATELLITE's full payload (4 column(s)), not to this
-- feeder's columns, so every feeder of SAT_POLICY_PREMIUM_HEAD is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   ace_premium_type_all_policy_n            1 attribute(s)
--   fixed_one_way_premium_all_policy_n       1 attribute(s)
--   fixed_round_trip_premium_all_policy_n    1 attribute(s)
--   gross_premium_all_policy_n               1 attribute(s)
--   one_way_premium_all_policy_n             1 attribute(s)
--   round_trip_premium_all_policy_n          1 attribute(s)
--   slab_all_policy_n                        1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'ALL' as COVERAGE_REFERENCE,
        'ACE_PREMIUM_TYPE' as PREMIUM_HEAD_CODE,
        'POLICY' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        ace_premium_type as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where ace_premium_type is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'ALL' as COVERAGE_REFERENCE,
        'FIXED_ONE_WAY_PREMIUM' as PREMIUM_HEAD_CODE,
        'POLICY' as SECTION,
        fixed_one_way_premium as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where fixed_one_way_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'ALL' as COVERAGE_REFERENCE,
        'FIXED_ROUND_TRIP_PREMIUM' as PREMIUM_HEAD_CODE,
        'POLICY' as SECTION,
        fixed_round_trip_premium as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where fixed_round_trip_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'ALL' as COVERAGE_REFERENCE,
        'GROSS_PREMIUM' as PREMIUM_HEAD_CODE,
        'POLICY' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        gross_premium as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where gross_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'ALL' as COVERAGE_REFERENCE,
        'ONE_WAY_PREMIUM' as PREMIUM_HEAD_CODE,
        'POLICY' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        one_way_premium as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where one_way_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'ALL' as COVERAGE_REFERENCE,
        'ROUND_TRIP_PREMIUM' as PREMIUM_HEAD_CODE,
        'POLICY' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        round_trip_premium as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where round_trip_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'ALL' as COVERAGE_REFERENCE,
        'SLAB' as PREMIUM_HEAD_CODE,
        'POLICY' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        slab_ as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where slab_ is not null
