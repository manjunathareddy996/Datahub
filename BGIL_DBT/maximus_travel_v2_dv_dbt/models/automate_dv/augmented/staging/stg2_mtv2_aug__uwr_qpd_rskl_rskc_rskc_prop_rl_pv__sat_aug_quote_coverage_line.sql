{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_COVERAGE_LINE from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 33 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl_rskc_rskc_prop_rl_pv'
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
  ACE_VARIANT_DEDUCTIBLE_AMOUNT: 'deductibleace'
  AMBULANCE_SUB_COVER_VALUE: 'ambulance_subcover'
  COMMON_CARRIER_TYPE: 'common_carrier_type'
  COVERAGE_BASE_CURRENCY_CODE: 'cover_level_base_currency'
  COVERAGE_END_DATE: 'cover_expiry_date'
  COVERAGE_LEVEL_EXCHANGE_RATE: 'forex_rate_at_cover_level'
  COVERAGE_LIMIT_AMOUNT: 'cast(null as varchar)'
  COVERAGE_MANUAL_DESCRIPTION: 'cover_description_manual'
  COVERAGE_PREMIUM_IN_BASE_CURRENCY: 'cover_premium_in_base_currency'
  COVERAGE_PREMIUM_IN_TRANSACTION_CURRENCY: 'cover_premium_in_transaction_currency'
  COVERAGE_START_DATE: 'cover_inception_date'
  COVERAGE_SUM_INSURED_CURRENCY_CODE: 'cover_level_transaction_currency_for_sum_insured'
  COVERAGE_SUM_INSURED_IN_BASE_CURRENCY: 'cover_sum_insured_in_base_currency'
  COVERAGE_SUM_INSURED_IN_TRANSACTION_CURRENCY: 'cover_sum_insured_in_transaction_currency'
  COVERAGE_TRANSACTION_CURRENCY_CODE: 'cover_level_transaction_currency'
  CO_PAYMENT_PERCENTAGE: 'copayace'
  DEDUCTIBLE_AMOUNT: 'deductible_value'
  DEDUCTIBLE_AMOUNT_FOR_INDIA_LOSSES: 'deductible_value_for_india'
  DEDUCTIBLE_AMOUNT_FOR_OVERSEAS_LOSSES: 'deductible_value_for_abroad'
  DEDUCTIBLE_APPLICATION_BASIS: 'basis_of_deductible'
  DEDUCTIBLE_COMPUTATION_BASIS: 'deductible_basis'
  DEDUCTIBLE_DESCRIPTOR: 'deductible'
  ENDORSEMENT_PREMIUM: 'cast(null as varchar)'
  FACULTATIVE_REINSURANCE_INDICATOR: 'cover_level_fac_ri'
  FACULTATIVE_REINSURANCE_PERCENTAGE: 'cover_level_fac_ri_percentage'
  GROSS_PREMIUM: 'cast(null as varchar)'
  MAXIMUM_COVER_PERIOD_DAYS: 'maximum_perioddays'
  MAXIMUM_SUM_INSURED: 'maximum_sum_insured'
  NET_PREMIUM_IN_PREMIUM_CURRENCY: 'cast(null as varchar)'
  NUMBER_OF_DAYS_COVERED: 'number_of_days'
  NUMBER_OF_WEEKS_COVERED: 'number_of_weeks'
  TRAVEL_INCONVENIENCE_SUB_COVER_VALUE: 'inconvenience_subcover'
  TRIP_CANCELLATION_SUB_COVER_VALUE: 'cancellation_subcover'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
