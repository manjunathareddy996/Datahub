{{ config(materialized='view') }}

-- UNPIVOT for SAT_QUOTE_RATING_INPUT from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
-- one row PER INSTANCE: 24 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by FACTOR_CODE.
-- The hash is taken once, downstream, by stg2_mtv2_up__uwr_qpd_polp_rl_pv__sat_quote_rating_input.
--
-- Payload is null-padded to the SATELLITE's full payload (3 column(s)), not to this
-- feeder's columns, so every feeder of SAT_QUOTE_RATING_INPUT is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   adjustment_value                         1 attribute(s)
--   altitude                                 1 attribute(s)
--   baggage_tracking_service_applicable      1 attribute(s)
--   claims_experience_discount               1 attribute(s)
--   claims_experience_loading                1 attribute(s)
--   clu_discount                             1 attribute(s)
--   country                                  1 attribute(s)
--   cruise                                   1 attribute(s)
--   cruise_days                              1 attribute(s)
--   destination_details                      1 attribute(s)
--   employee_discount                        1 attribute(s)
--   geographical_coverage                    1 attribute(s)
--   group_discount                           1 attribute(s)
--   hours_covered                            1 attribute(s)
--   mode_of_transport                        1 attribute(s)
--   multiple_city                            1 attribute(s)
--   nil_commission_discount                  1 attribute(s)
--   online_discount                          1 attribute(s)
--   other_discount                           1 attribute(s)
--   premium_adjustment                       1 attribute(s)
--   student_discount                         1 attribute(s)
--   travelling_companion_discount            1 attribute(s)
--   type_of_discount                         1 attribute(s)
--   type_of_loading                          1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ADJUSTMENT_VALUE' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        adjustment_value as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where adjustment_value is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ALTITUDE' as FACTOR_CODE,
        altitude as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where altitude is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'BAGGAGE_TRACKING_SERVICE_APPLICABLE' as FACTOR_CODE,
        baggage_tracking_service_applicable as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where baggage_tracking_service_applicable is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'CLAIMS_EXPERIENCE_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        claims_experience_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where claims_experience_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'CLAIMS_EXPERIENCE_LOADING' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        claims_experience_loading as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where claims_experience_loading is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'CLU_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        clu_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where clu_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'COUNTRY' as FACTOR_CODE,
        country as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where country is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'CRUISE' as FACTOR_CODE,
        cruise as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where cruise is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'CRUISE_DAYS' as FACTOR_CODE,
        cruise_days as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where cruise_days is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'DESTINATION_DETAILS' as FACTOR_CODE,
        destination_details as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where destination_details is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'EMPLOYEE_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        employee_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where employee_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'GEOGRAPHICAL_COVERAGE' as FACTOR_CODE,
        geographical_coverage as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where geographical_coverage is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'GROUP_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        group_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where group_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'HOURS_COVERED' as FACTOR_CODE,
        hours_covered as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where hours_covered is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'MODE_OF_TRANSPORT' as FACTOR_CODE,
        mode_of_transport as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where mode_of_transport is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'MULTIPLE_CITY' as FACTOR_CODE,
        multiple_city as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where multiple_city is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'NIL_COMMISSION_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        nil_commission_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where nil_commission_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ONLINE_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        online_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where online_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'OTHER_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        other_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where other_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'PREMIUM_ADJUSTMENT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        premium_adjustment as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where premium_adjustment is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'STUDENT_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        student_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where student_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'TRAVELLING_COMPANION_DISCOUNT' as FACTOR_CODE,
        cast(null as varchar) as FACTOR_VALUE,
        travelling_companion_discount as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where travelling_companion_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'TYPE_OF_DISCOUNT' as FACTOR_CODE,
        type_of_discount as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where type_of_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'TYPE_OF_LOADING' as FACTOR_CODE,
        type_of_loading as FACTOR_VALUE,
        cast(null as varchar) as PREMIUM_IMPACT,
        cast(null as varchar) as RELATIVITY_APPLIED,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_rl_pv') }}
    where type_of_loading is not null
