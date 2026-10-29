{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- Covers this view's 3 key slot(s) and its 5 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   COVERAGE_HKEY                      HUB_COVERAGE  (3 row(s) in the map)
--   POLICY_HKEY                        HUB_POLICY  (84 row(s) in the map)
--   RISK_OBJECT_HKEY                   HUB_RISK_OBJECT  (3 row(s) in the map)
--   HASHDIFF_COVERAGE_CONDITIONS       SAT_COVERAGE_CONDITIONS payload 1 of 1 live here
--   HASHDIFF_COVERAGE_DEFINITION       SAT_COVERAGE_DEFINITION payload 1 of 3 live here
--   HASHDIFF_POLICY_COVERAGE_SCHEDULE  SAT_POLICY_COVERAGE_SCHEDULE payload 6 of 8 live here
--   HASHDIFF_POLICY_SUM_INSURED_BREAKUP SAT_POLICY_SUM_INSURED_BREAKUP payload 2 of 3 live here
--   HASHDIFF_RISK_PERSON_TRAVEL        SAT_RISK_PERSON_TRAVEL payload 2 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins_cov_covp_sp_pv'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  POLICY_HKEY: 'POLICY_NK'
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
  HASHDIFF_POLICY_COVERAGE_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'COVERAGE_END_DATE'
      - 'COVERAGE_OPTED_INDICATOR'
      - 'COVERAGE_REFERENCE'
      - 'COVERAGE_SEQUENCE'
      - 'COVERAGE_START_DATE'
      - 'CO_PAYMENT_PERCENTAGE'
      - 'DEDUCTIBLE_AMOUNT'
      - 'LIMIT_AMOUNT'
      - 'PREMIUM_FOR_COVERAGE'
      - 'SUM_INSURED'
  HASHDIFF_POLICY_SUM_INSURED_BREAKUP:
    is_hashdiff: true
    columns:
      - 'SUM_INSURED_AMOUNT'
      - 'SUM_INSURED_BREAK_UP_DETAIL'
      - 'SUM_INSURED_HEAD'
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
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  RISK_OBJECT_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),'')"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),''), nullif(trim(w1_pol_risk_id),'')) is not null then 'RISK:' || coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) || '#' || nullif(trim(w1_pol_risk_id), '') end),''))"
  CONDITION_DESCRIPTION: 'sub_condition1'
  COVERAGE_DESCRIPTION: 'cover_description'
  COVERAGE_END_DATE: 'cover_expiry_date'
  COVERAGE_NAME: 'cast(null as varchar)'
  COVERAGE_OPTED_INDICATOR: 'cast(null as varchar)'
  COVERAGE_REFERENCE: "coalesce(nullif(trim(w2_cover_code), ''),'')"
  COVERAGE_SEQUENCE: "coalesce(nullif(trim(w1_pol_risk_id), ''),'')"
  COVERAGE_START_DATE: 'cover_inception_date'
  CO_PAYMENT_PERCENTAGE: 'copayace'
  DEDUCTIBLE_AMOUNT: 'deductible_value'
  DESTINATION_COUNTRY: 'cast(null as varchar)'
  GEOGRAPHICAL_ZONE: 'cast(null as varchar)'
  LIMIT_AMOUNT: 'cast(null as varchar)'
  PERIL_COVERED: 'cast(null as varchar)'
  PREMIUM_FOR_COVERAGE: 'cover_premium_in_transaction_currency'
  SUM_INSURED: 'sum_insured'
  SUM_INSURED_AMOUNT: 'coalesce(cover_sum_insured_in_transaction_currency, sum_insuredace, total_sum_insured, si_per_unit, si_for_abroad_in_usd, si_for_india_in_inr)'
  SUM_INSURED_HEAD: "nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || coalesce(nullif(trim(w2_cover_code), ''), '') || '#' || 'COVER_SI_TXN_CCY'), '##COVER_SI_TXN_CCY')"
  TRIP_DURATION: 'trip_durationace'
  TRIP_END_DATE: 'cast(null as varchar)'
  TRIP_START_DATE: 'cast(null as varchar)'
  TRIP_TYPE: 'trip_typeace_domestic'
  SUM_INSURED_BREAK_UP_DETAIL: 'sum_insured_break_up'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
