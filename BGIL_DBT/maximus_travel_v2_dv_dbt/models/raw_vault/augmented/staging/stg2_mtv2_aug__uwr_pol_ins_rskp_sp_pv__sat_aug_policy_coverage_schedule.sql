{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_COVERAGE_SCHEDULE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 29 payload column(s); the child key is COVERAGE_REFERENCE, COVERAGE_SEQUENCE.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_rskp_sp_pv'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_COVERAGE_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'ACE_VARIANT_DEDUCTIBLE_AMOUNT'
      - 'AMBULANCE_SUB_COVER_VALUE'
      - 'BENEFIT_UNIT_IN_HOURS'
      - 'BUSINESS_EVENT_CODE'
      - 'COMMON_CARRIER_TYPE'
      - 'COVERAGE_BASE_CURRENCY_CODE'
      - 'COVERAGE_LEVEL_EXCHANGE_RATE'
      - 'COVERAGE_MANUAL_DESCRIPTION'
      - 'COVERAGE_REFERENCE'
      - 'COVERAGE_SEQUENCE'
      - 'COVERAGE_SUM_INSURED_CURRENCY_CODE'
      - 'COVERAGE_TERM'
      - 'COVERAGE_TRANSACTION_CURRENCY_CODE'
      - 'DEDUCTIBLE_AMOUNT_FOR_INDIA_LOSSES'
      - 'DEDUCTIBLE_AMOUNT_FOR_OVERSEAS_LOSSES'
      - 'DEDUCTIBLE_APPLICATION_BASIS'
      - 'DEDUCTIBLE_COMPUTATION_BASIS'
      - 'DEDUCTIBLE_DESCRIPTOR'
      - 'FACULTATIVE_REINSURANCE_INDICATOR'
      - 'FACULTATIVE_REINSURANCE_PERCENTAGE'
      - 'MAXIMUM_COVER_PERIOD_DAYS'
      - 'MAXIMUM_SUM_INSURED'
      - 'NUMBER_OF_DAYS_COVERED'
      - 'NUMBER_OF_WEEKS_COVERED'
      - 'PAYOUT_OPTION'
      - 'PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY'
      - 'SUB_LIMIT_DETAIL'
      - 'SUM_INSURED_IN_BASE_CURRENCY'
      - 'TRAVEL_INCONVENIENCE_SUB_COVER_VALUE'
      - 'TRIP_CANCELLATION_SUB_COVER_VALUE'
      - 'TRIP_DELAY_OPTION'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  COVERAGE_REFERENCE: "coalesce(nullif(trim(cover_code), ''),'')"
  COVERAGE_SEQUENCE: "coalesce(nullif(trim(w1_pol_risk_id), ''),'')"
  ACE_VARIANT_DEDUCTIBLE_AMOUNT: 'cast(null as varchar)'
  AMBULANCE_SUB_COVER_VALUE: 'cast(null as varchar)'
  BENEFIT_UNIT_IN_HOURS: 'cast(null as varchar)'
  BUSINESS_EVENT_CODE: 'cast(null as varchar)'
  COMMON_CARRIER_TYPE: 'cast(null as varchar)'
  COVERAGE_BASE_CURRENCY_CODE: 'cover_level_base_currency'
  COVERAGE_LEVEL_EXCHANGE_RATE: 'cast(null as varchar)'
  COVERAGE_MANUAL_DESCRIPTION: 'cast(null as varchar)'
  COVERAGE_SUM_INSURED_CURRENCY_CODE: 'cover_level_transaction_currency_for_sum_insured'
  COVERAGE_TERM: 'cast(null as varchar)'
  COVERAGE_TRANSACTION_CURRENCY_CODE: 'cover_level_transaction_currency'
  DEDUCTIBLE_AMOUNT_FOR_INDIA_LOSSES: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT_FOR_OVERSEAS_LOSSES: 'cast(null as varchar)'
  DEDUCTIBLE_APPLICATION_BASIS: 'cast(null as varchar)'
  DEDUCTIBLE_COMPUTATION_BASIS: 'cast(null as varchar)'
  DEDUCTIBLE_DESCRIPTOR: 'cast(null as varchar)'
  FACULTATIVE_REINSURANCE_INDICATOR: 'cast(null as varchar)'
  FACULTATIVE_REINSURANCE_PERCENTAGE: 'cast(null as varchar)'
  MAXIMUM_COVER_PERIOD_DAYS: 'cast(null as varchar)'
  MAXIMUM_SUM_INSURED: 'cast(null as varchar)'
  NUMBER_OF_DAYS_COVERED: 'cast(null as varchar)'
  NUMBER_OF_WEEKS_COVERED: 'cast(null as varchar)'
  PAYOUT_OPTION: 'cast(null as varchar)'
  PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY: 'cover_premium_in_base_currency'
  SUB_LIMIT_DETAIL: 'cast(null as varchar)'
  SUM_INSURED_IN_BASE_CURRENCY: 'cover_sum_insured_in_base_currency'
  TRAVEL_INCONVENIENCE_SUB_COVER_VALUE: 'cast(null as varchar)'
  TRIP_CANCELLATION_SUB_COVER_VALUE: 'cast(null as varchar)'
  TRIP_DELAY_OPTION: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
