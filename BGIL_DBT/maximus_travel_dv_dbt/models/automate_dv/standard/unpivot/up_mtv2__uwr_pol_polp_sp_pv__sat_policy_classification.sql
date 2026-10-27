{{ config(materialized='view') }}

-- UNPIVOT for SAT_POLICY_CLASSIFICATION from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 4 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by CLASSIFICATION_TYPE.
-- The hash is taken once, downstream, by stg2_mtv2_up__uwr_pol_polp_sp_pv__sat_policy_classification.
--
-- Payload is null-padded to the SATELLITE's full payload (1 column(s)), not to this
-- feeder's columns, so every feeder of SAT_POLICY_CLASSIFICATION is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   policy_plan                              1 attribute(s)
--   source_of_business                       1 attribute(s)
--   type_of_business                         1 attribute(s)
--   type_of_tour                             1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'POLICY_PLAN' as CLASSIFICATION_TYPE,
        policy_plan as CLASSIFICATION_VALUE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_sp_pv') }}
    where policy_plan is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'SOURCE_OF_BUSINESS' as CLASSIFICATION_TYPE,
        source_of_business as CLASSIFICATION_VALUE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_sp_pv') }}
    where source_of_business is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'TYPE_OF_BUSINESS' as CLASSIFICATION_TYPE,
        type_of_business as CLASSIFICATION_VALUE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_sp_pv') }}
    where type_of_business is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'TYPE_OF_TOUR' as CLASSIFICATION_TYPE,
        type_of_tour as CLASSIFICATION_VALUE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_polp_sp_pv') }}
    where type_of_tour is not null
