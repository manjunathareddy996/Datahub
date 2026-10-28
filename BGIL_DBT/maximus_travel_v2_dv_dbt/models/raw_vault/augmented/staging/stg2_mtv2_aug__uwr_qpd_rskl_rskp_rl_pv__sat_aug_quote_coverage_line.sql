{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_COVERAGE_LINE from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 33 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl_rskp_rl_pv'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_COVERAGE_LINE:
    is_hashdiff: true
    columns:
      - 'ACE_VARIANT_DEDUCTIBLE_AMOUNT'
      - 'AMBULANCE_SUB_COVER_VALUE'
      - 'COMMON_CARRIER_TYPE'
      - 'COVERAGE_BASE_CURRENCY_CODE'
      - 'COVERAGE_END_DATE'
      - 'COVERAGE_LEVEL_EXCHANGE_RATE'
      - 'COVERAGE_LIMIT_AMOUNT'
      - 'COVERAGE_MANUAL_DESCRIPTION'
      - 'COVERAGE_PREMIUM_IN_BASE_CURRENCY'
      - 'COVERAGE_PREMIUM_IN_TRANSACTION_CURRENCY'
      - 'COVERAGE_START_DATE'
      - 'COVERAGE_SUM_INSURED_CURRENCY_CODE'
      - 'COVERAGE_SUM_INSURED_IN_BASE_CURRENCY'
      - 'COVERAGE_SUM_INSURED_IN_TRANSACTION_CURRENCY'
      - 'COVERAGE_TRANSACTION_CURRENCY_CODE'
      - 'CO_PAYMENT_PERCENTAGE'
      - 'DEDUCTIBLE_AMOUNT'
      - 'DEDUCTIBLE_AMOUNT_FOR_INDIA_LOSSES'
      - 'DEDUCTIBLE_AMOUNT_FOR_OVERSEAS_LOSSES'
      - 'DEDUCTIBLE_APPLICATION_BASIS'
      - 'DEDUCTIBLE_COMPUTATION_BASIS'
      - 'DEDUCTIBLE_DESCRIPTOR'
      - 'ENDORSEMENT_PREMIUM'
      - 'FACULTATIVE_REINSURANCE_INDICATOR'
      - 'FACULTATIVE_REINSURANCE_PERCENTAGE'
      - 'GROSS_PREMIUM'
      - 'MAXIMUM_COVER_PERIOD_DAYS'
      - 'MAXIMUM_SUM_INSURED'
      - 'NET_PREMIUM_IN_PREMIUM_CURRENCY'
      - 'NUMBER_OF_DAYS_COVERED'
      - 'NUMBER_OF_WEEKS_COVERED'
      - 'TRAVEL_INCONVENIENCE_SUB_COVER_VALUE'
      - 'TRIP_CANCELLATION_SUB_COVER_VALUE'
derived_columns:
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  ACE_VARIANT_DEDUCTIBLE_AMOUNT: 'cast(null as varchar)'
  AMBULANCE_SUB_COVER_VALUE: 'cast(null as varchar)'
  COMMON_CARRIER_TYPE: 'cast(null as varchar)'
  COVERAGE_BASE_CURRENCY_CODE: 'cover_level_base_currency'
  COVERAGE_END_DATE: 'cover_expiry_date'
  COVERAGE_LEVEL_EXCHANGE_RATE: 'cast(null as varchar)'
  COVERAGE_LIMIT_AMOUNT: 'limit'
  COVERAGE_MANUAL_DESCRIPTION: 'cast(null as varchar)'
  COVERAGE_PREMIUM_IN_BASE_CURRENCY: 'cover_premium_in_base_currency'
  COVERAGE_PREMIUM_IN_TRANSACTION_CURRENCY: 'cover_premium_in_transaction_currency'
  COVERAGE_START_DATE: 'cover_inception_date'
  COVERAGE_SUM_INSURED_CURRENCY_CODE: 'cover_level_transaction_currency_for_sum_insured'
  COVERAGE_SUM_INSURED_IN_BASE_CURRENCY: 'cover_sum_insured_in_base_currency'
  COVERAGE_SUM_INSURED_IN_TRANSACTION_CURRENCY: 'cover_sum_insured_in_transaction_currency'
  COVERAGE_TRANSACTION_CURRENCY_CODE: 'cover_level_transaction_currency'
  CO_PAYMENT_PERCENTAGE: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT_FOR_INDIA_LOSSES: 'cast(null as varchar)'
  DEDUCTIBLE_AMOUNT_FOR_OVERSEAS_LOSSES: 'cast(null as varchar)'
  DEDUCTIBLE_APPLICATION_BASIS: 'cast(null as varchar)'
  DEDUCTIBLE_COMPUTATION_BASIS: 'cast(null as varchar)'
  DEDUCTIBLE_DESCRIPTOR: 'cast(null as varchar)'
  ENDORSEMENT_PREMIUM: 'endorsement_premium'
  FACULTATIVE_REINSURANCE_INDICATOR: 'cast(null as varchar)'
  FACULTATIVE_REINSURANCE_PERCENTAGE: 'cast(null as varchar)'
  GROSS_PREMIUM: 'gross_premium'
  MAXIMUM_COVER_PERIOD_DAYS: 'cast(null as varchar)'
  MAXIMUM_SUM_INSURED: 'cast(null as varchar)'
  NET_PREMIUM_IN_PREMIUM_CURRENCY: 'net_premium_in_premium_currency'
  NUMBER_OF_DAYS_COVERED: 'cast(null as varchar)'
  NUMBER_OF_WEEKS_COVERED: 'cast(null as varchar)'
  TRAVEL_INCONVENIENCE_SUB_COVER_VALUE: 'cast(null as varchar)'
  TRIP_CANCELLATION_SUB_COVER_VALUE: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
