{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_COVER_DETAIL from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 15 payload column(s); the child key is COVERAGE_REFERENCE, COVERAGE_SEQUENCE.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_rskl_rskc_rskc_prop_rl_pv'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_COVER_DETAIL:
    is_hashdiff: true
    columns:
      - 'BENEFIT_UNIT_IN_HOURS'
      - 'COVERAGE_REFERENCE'
      - 'COVERAGE_SEQUENCE'
      - 'COVER_PERIOD'
      - 'COVER_PREMIUM_AMOUNT'
      - 'COVER_PREMIUM_AMOUNT_IN_BASE_CURRENCY'
      - 'COVER_SUM_INSURED'
      - 'COVER_SUM_INSURED_ACE_VARIANT'
      - 'COVER_SUM_INSURED_FOR_ABROAD_IN_USD'
      - 'COVER_SUM_INSURED_FOR_INDIA_IN_INR'
      - 'PAYOUT_OPTION'
      - 'PRIOR_COVER_PREMIUM_AMOUNT'
      - 'SUB_LIMIT_DETAIL'
      - 'SUM_INSURED_BREAK_UP_DETAIL'
      - 'SUM_INSURED_PER_UNIT'
      - 'TOTAL_COVER_SUM_INSURED'
      - 'TRIP_DELAY_OPTION'
derived_columns:
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  COVERAGE_REFERENCE: "'RISK:' || nullif(trim(w1_pol_risk_id), '') || '#' || nullif(trim(w2_cover_code), '')"
  COVERAGE_SEQUENCE: "'1'"
  BENEFIT_UNIT_IN_HOURS: 'unit_in_hours'
  COVER_PERIOD: 'period'
  COVER_PREMIUM_AMOUNT: 'premium'
  COVER_PREMIUM_AMOUNT_IN_BASE_CURRENCY: 'update_cover_premium_in_base_currency'
  COVER_SUM_INSURED: 'sum_insured'
  COVER_SUM_INSURED_ACE_VARIANT: 'sum_insuredace'
  COVER_SUM_INSURED_FOR_ABROAD_IN_USD: 'si_for_abroad_in_usd'
  COVER_SUM_INSURED_FOR_INDIA_IN_INR: 'si_for_india_in_inr'
  PAYOUT_OPTION: 'payout_optionace'
  PRIOR_COVER_PREMIUM_AMOUNT: 'old_premium'
  SUB_LIMIT_DETAIL: 'sublimit_details'
  SUM_INSURED_BREAK_UP_DETAIL: 'sum_insured_break_up'
  SUM_INSURED_PER_UNIT: 'si_per_unit'
  TOTAL_COVER_SUM_INSURED: 'total_sum_insured'
  TRIP_DELAY_OPTION: 'trip_delay_option'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
