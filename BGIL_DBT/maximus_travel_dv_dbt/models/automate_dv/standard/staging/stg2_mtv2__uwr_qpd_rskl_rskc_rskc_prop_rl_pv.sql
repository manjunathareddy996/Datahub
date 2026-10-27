{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
-- Covers this view's 3 key slot(s) and its 4 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mtv2_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   COVERAGE_HKEY                      HUB_COVERAGE  (3 row(s) in the map)
--   QUOTE_HKEY                         HUB_QUOTE  (84 row(s) in the map)
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (3 row(s) in the map)
--   HASHDIFF_COVERAGE_CONDITIONS       SAT_COVERAGE_CONDITIONS payload 1 of 1 live here
--   HASHDIFF_COVERAGE_DEFINITION       SAT_COVERAGE_DEFINITION payload 1 of 3 live here
--   HASHDIFF_QUOTE_RATING_INPUT        SAT_QUOTE_RATING_INPUT payload 2 of 3 live here
--   HASHDIFF_RISK_PERSON_TRAVEL        SAT_RISK_PERSON_TRAVEL payload 2 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl_rskc_rskc_prop_rl_pv'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF_COVERAGE_CONDITIONS:
    is_hashdiff: true
    columns:
      - 'CONDITION_DESCRIPTION'
  HASHDIFF_COVERAGE_DEFINITION:
    is_hashdiff: true
    columns:
      - 'COVERAGE_DESCRIPTION'
      - 'COVERAGE_NAME'
      - 'PERIL_COVERED'
  HASHDIFF_QUOTE_RATING_INPUT:
    is_hashdiff: true
    columns:
      - 'FACTOR_CODE'
      - 'FACTOR_VALUE'
      - 'PREMIUM_IMPACT'
      - 'RELATIVITY_APPLIED'
  HASHDIFF_RISK_PERSON_TRAVEL:
    is_hashdiff: true
    columns:
      - 'DESTINATION_COUNTRY'
      - 'GEOGRAPHICAL_ZONE'
      - 'TRIP_DURATION'
      - 'TRIP_END_DATE'
      - 'TRIP_START_DATE'
      - 'TRIP_TYPE'
derived_columns:
  COVERAGE_BK: "nullif(trim(case when coalesce(nullif(trim(w2_cover_code),'')) is not null then 'COV:' || nullif(trim(w2_cover_code), '') end),'')"
  COVERAGE_NK: "'HUB_COVERAGE|' || (nullif(trim(case when coalesce(nullif(trim(w2_cover_code),'')) is not null then 'COV:' || nullif(trim(w2_cover_code), '') end),''))"
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || nullif(trim(w0_policy_quote_number), '') || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  CONDITION_DESCRIPTION: 'sub_condition1'
  COVERAGE_DESCRIPTION: 'cover_description'
  COVERAGE_NAME: 'cast(null as varchar)'
  DESTINATION_COUNTRY: 'cast(null as varchar)'
  FACTOR_CODE: "nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(w2_cover_code), ''), '') || '#' || 'BASE_AMT_ON_CURRENT_PMM_SLAB'), '##BASE_AMT_ON_CURRENT_PMM_SLAB')"
  FACTOR_VALUE: 'coalesce(base_amt_on_current_pmm_slab, office_premium_per_mile, office_premium_per_mileloading, office_premium_per_mille_accident_only, office_premium_per_mille_emergency_opd_expenses_for_sickness, office_premium_per_mille_pa, office_premium_per_mille_pa_accident_only, office_premium_per_mille_pa_air_ambulance, office_premium_per_mille_pa_death, office_premium_per_mille_pa_for_sickness_only, office_premium_per_mille_pa_fracture_care_benefit, office_premium_per_mille_pa_ppd, office_premium_per_mille_pa_ptd, office_premium_per_mille_pa_repatriation_of_mortal_remains, office_premium_per_mille_pa_replacement_and_rearrangement_of_staff, office_premium_per_mille_pa_road, office_premium_per_mille_per_trip, pmm_adj_factor_for_prd_elapsed, pmm_adj_factor_for_prd_remain, pmm_adj_factor_for_product_remain, relativityace, risk_factorace, risk_load_factorace, short_term_factorace, rate, rateace_domestic, rate_for_daily_allowance_pa, premium_per_day, rate_basisace_domestic, slab_details)'
  GEOGRAPHICAL_ZONE: 'cast(null as varchar)'
  PERIL_COVERED: 'cast(null as varchar)'
  PREMIUM_IMPACT: 'cast(null as varchar)'
  RELATIVITY_APPLIED: 'common_carrier_relativity'
  TRIP_DURATION: 'trip_durationace'
  TRIP_END_DATE: 'cast(null as varchar)'
  TRIP_START_DATE: 'cast(null as varchar)'
  TRIP_TYPE: 'trip_typeace_domestic'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
