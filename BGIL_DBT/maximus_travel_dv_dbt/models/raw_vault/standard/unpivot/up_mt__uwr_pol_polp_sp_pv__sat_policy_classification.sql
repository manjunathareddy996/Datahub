{{ config(materialized='view') }}

-- UNPIVOT for SAT_POLICY_CLASSIFICATION from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 4 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by CLASSIFICATION_TYPE.
-- The hash is taken once, downstream, by stg2_mt_up__uwr_pol_polp_sp_pv__sat_policy_classification.
--
-- Payload is null-padded to the SATELLITE's full payload (1 column(s)), not to this
-- feeder's columns, so every feeder of SAT_POLICY_CLASSIFICATION is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   policy_plan                              1 attribute(s)
--   source_of_business                       1 attribute(s)
--   type_of_business                         1 attribute(s)
--   type_of_tour                             1 attribute(s)

-- INCREMENTAL VIEW: returns only rows whose REC_REFRESH_AT is after the latest
-- LOAD_DATETIME this feeder already wrote to SAT_POLICY_CLASSIFICATION.
--   Incremental (default):  dbt run -s +sat_policy_classification
--   Full load:              dbt run -s +sat_policy_classification --vars '{full_load: true}'
--   (--full-refresh, or SAT_POLICY_CLASSIFICATION not existing yet, also gives full data)

{%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier='SAT_POLICY_CLASSIFICATION') if execute else none %}
{%- set is_full_load = var('full_load', false) or flags.FULL_REFRESH or sat_rel is none %}

with src as (
    select *
    from {{ ref('resolved_mt__uwr_pol_polp_sp_pv') }}
    {%- if not is_full_load %}
    where try_to_timestamp_ntz(to_varchar(rec_refresh_at)) > (
        select coalesce(max(try_to_timestamp_ntz(to_varchar(LOAD_DATETIME))), '1900-01-01'::timestamp_ntz)
        from {{ sat_rel }}
        where RECORD_SOURCE = 'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
    )
    {%- endif %}
)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'POLICY_PLAN' as CLASSIFICATION_TYPE,
        policy_plan as CLASSIFICATION_VALUE,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where policy_plan is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'SOURCE_OF_BUSINESS' as CLASSIFICATION_TYPE,
        source_of_business as CLASSIFICATION_VALUE,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where source_of_business is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'TYPE_OF_BUSINESS' as CLASSIFICATION_TYPE,
        type_of_business as CLASSIFICATION_VALUE,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where type_of_business is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'TYPE_OF_TOUR' as CLASSIFICATION_TYPE,
        type_of_tour as CLASSIFICATION_VALUE,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where type_of_tour is not null
