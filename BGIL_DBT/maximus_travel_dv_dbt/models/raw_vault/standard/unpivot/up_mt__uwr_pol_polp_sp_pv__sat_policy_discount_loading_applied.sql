{{ config(materialized='view') }}

-- UNPIVOT for SAT_POLICY_DISCOUNT_LOADING_APPLIED from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 14 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by ITEM_CODE.
-- The hash is taken once, downstream, by stg2_mt_up__uwr_pol_polp_sp_pv__sat_policy_discount_loading_applied.
--
-- Payload is null-padded to the SATELLITE's full payload (3 column(s)), not to this
-- feeder's columns, so every feeder of SAT_POLICY_DISCOUNT_LOADING_APPLIED is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   adjustment_value                         1 attribute(s)
--   claims_experience_discount               1 attribute(s)
--   claims_experience_loading                1 attribute(s)
--   clu_discount                             1 attribute(s)
--   discount                                 1 attribute(s)
--   employee_discount                        1 attribute(s)
--   group_discount                           1 attribute(s)
--   loading                                  1 attribute(s)
--   nil_commission_discount                  1 attribute(s)
--   online_discount                          1 attribute(s)
--   other_discount                           1 attribute(s)
--   premium_adjustment                       1 attribute(s)
--   student_discount                         1 attribute(s)
--   travelling_companion_discount            1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'ADJUSTMENT_VALUE' as ITEM_CODE,
        adjustment_value as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where adjustment_value is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'CLAIMS_EXPERIENCE_DISCOUNT' as ITEM_CODE,
        claims_experience_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where claims_experience_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'CLAIMS_EXPERIENCE_LOADING' as ITEM_CODE,
        claims_experience_loading as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where claims_experience_loading is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'CLU_DISCOUNT' as ITEM_CODE,
        clu_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where clu_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'DISCOUNT' as ITEM_CODE,
        cast(null as varchar) as AMOUNT_APPLIED,
        type_of_discount as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where type_of_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'EMPLOYEE_DISCOUNT' as ITEM_CODE,
        employee_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where employee_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'GROUP_DISCOUNT' as ITEM_CODE,
        group_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where group_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'LOADING' as ITEM_CODE,
        cast(null as varchar) as AMOUNT_APPLIED,
        type_of_loading as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where type_of_loading is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'NIL_COMMISSION_DISCOUNT' as ITEM_CODE,
        nil_commission_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where nil_commission_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'ONLINE_DISCOUNT' as ITEM_CODE,
        online_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where online_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'OTHER_DISCOUNT' as ITEM_CODE,
        other_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where other_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'PREMIUM_ADJUSTMENT' as ITEM_CODE,
        premium_adjustment as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where premium_adjustment is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'STUDENT_DISCOUNT' as ITEM_CODE,
        student_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where student_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'TRAVELLING_COMPANION_DISCOUNT' as ITEM_CODE,
        travelling_companion_discount as AMOUNT_APPLIED,
        cast(null as varchar) as ITEM_TYPE,
        cast(null as varchar) as PERCENTAGE_APPLIED,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    where travelling_companion_discount is not null
