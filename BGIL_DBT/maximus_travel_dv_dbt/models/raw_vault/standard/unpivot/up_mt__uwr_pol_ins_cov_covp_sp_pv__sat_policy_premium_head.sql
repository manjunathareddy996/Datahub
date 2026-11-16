{{ config(materialized='view') }}

-- UNPIVOT for SAT_POLICY_PREMIUM_HEAD from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 9 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by ADJUSTED_INDICATOR, COVERAGE_REFERENCE, PREMIUM_HEAD_CODE, SECTION.
-- The hash is taken once, downstream, by stg2_mt_up__uwr_pol_ins_cov_covp_sp_pv__sat_policy_premium_head.
--
-- Payload is null-padded to the SATELLITE's full payload (4 column(s)), not to this
-- feeder's columns, so every feeder of SAT_POLICY_PREMIUM_HEAD is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   accidental_premium_ace_cover_n           1 attribute(s)
--   cover_old_premium_cover_n                1 attribute(s)
--   cover_premium_cover_n                    1 attribute(s)
--   emergency_hospitalization_sickness_premi_f55d63 1 attribute(s)
--   loading_cover_n                          1 attribute(s)
--   net_premium_cover_n                      1 attribute(s)
--   net_premium_without_loading_discount_cover_n 1 attribute(s)
--   rateace_domestic_cover_n                 1 attribute(s)
--   updated_cover_premium_base_ccy_cover_n   1 attribute(s)

-- INCREMENTAL VIEW: returns only rows whose REC_REFRESH_AT is after the latest
-- LOAD_DATETIME this feeder already wrote to SAT_POLICY_PREMIUM_HEAD.
--   Incremental (default):  dbt run -s +sat_policy_premium_head
--   Full load:              dbt run -s +sat_policy_premium_head --vars '{full_load: true}'
--   (--full-refresh, or SAT_POLICY_PREMIUM_HEAD not existing yet, also gives full data)

{%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier='SAT_POLICY_PREMIUM_HEAD') if execute else none %}
{%- set is_full_load = var('full_load', false) or flags.FULL_REFRESH or sat_rel is none %}

with src as (
    select *
    from {{ ref('resolved_mt__uwr_pol_ins_cov_covp_sp_pv') }}
    {%- if not is_full_load %}
    where try_to_timestamp_ntz(to_varchar(rec_refresh_at)) > (
        select coalesce(max(try_to_timestamp_ntz(to_varchar(LOAD_DATETIME))), '1900-01-01'::timestamp_ntz)
        from {{ sat_rel }}
        where RECORD_SOURCE = 'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
    )
    {%- endif %}
)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(w2_cover_code), ''), '')), '#') as COVERAGE_REFERENCE,
        'ACCIDENTAL_PREMIUM_ACE' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        accidental_premiumace as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where accidental_premiumace is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'RISK:' || nullif(trim(w1_pol_risk_id), '') || '#' || nullif(trim(w2_cover_code), '') as COVERAGE_REFERENCE,
        'COVER_OLD_PREMIUM' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        old_premium as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where old_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'RISK:' || nullif(trim(w1_pol_risk_id), '') || '#' || nullif(trim(w2_cover_code), '') as COVERAGE_REFERENCE,
        'COVER_PREMIUM' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        premium as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(w2_cover_code), ''), '')), '#') as COVERAGE_REFERENCE,
        'EMERGENCY_HOSPITALIZATION_SICKNESS_PREMIUM' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        emergency_hospitalization_for_sickness_premium as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where emergency_hospitalization_for_sickness_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(w2_cover_code), ''), '')), '#') as COVERAGE_REFERENCE,
        'LOADING' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        loading as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where loading is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(w2_cover_code), ''), '')), '#') as COVERAGE_REFERENCE,
        'NET_PREMIUM' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        net_premium as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where net_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(w2_cover_code), ''), '')), '#') as COVERAGE_REFERENCE,
        'NET_PREMIUM_WITHOUT_LOADING_DISCOUNT' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        net_premium_without_loading_discount as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where net_premium_without_loading_discount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'RISK:' || nullif(trim(w1_pol_risk_id), '') || '#' || nullif(trim(w2_cover_code), '') as COVERAGE_REFERENCE,
        'RATEACE_DOMESTIC' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        rate_basisace_domestic as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where rate_basisace_domestic is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        'RISK:' || nullif(trim(w1_pol_risk_id), '') || '#' || nullif(trim(w2_cover_code), '') as COVERAGE_REFERENCE,
        'UPDATED_COVER_PREMIUM_BASE_CCY' as PREMIUM_HEAD_CODE,
        'COVER' as SECTION,
        update_cover_premium_in_base_currency as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from src
    where update_cover_premium_in_base_currency is not null
