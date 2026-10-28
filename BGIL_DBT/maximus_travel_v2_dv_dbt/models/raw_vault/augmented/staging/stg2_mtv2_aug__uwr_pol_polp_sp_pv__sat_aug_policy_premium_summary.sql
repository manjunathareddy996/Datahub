{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_PREMIUM_SUMMARY from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 21 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_polp_sp_pv'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_POLICY_PREMIUM_SUMMARY:
    is_hashdiff: true
    columns:
      - 'ADDITIONAL_PREMIUM_AMOUNT'
      - 'ADMINISTRATION_CHARGES_AMOUNT'
      - 'AUTO_ADJUSTED_PREMIUM_AMOUNT'
      - 'AUTO_ADJUSTMENT_DISCOUNT_LIMIT_AMOUNT'
      - 'AUTO_ADJUSTMENT_LOADING_LIMIT_AMOUNT'
      - 'BANK_CHARGES_AMOUNT'
      - 'MANUAL_REFUND_AMOUNT'
      - 'NET_PREMIUM_IN_PREMIUM_CURRENCY'
      - 'POLICY_PREMIUM_IN_BASE_CURRENCY'
      - 'POLICY_PREMIUM_IN_TRANSACTION_CURRENCY'
      - 'POLICY_PREMIUM_VALUE'
      - 'PREMIUM_AFTER_LOADING_AMOUNT'
      - 'PREMIUM_BEFORE_LOADING_AMOUNT'
      - 'PREMIUM_CALCULATOR_URN'
      - 'PREMIUM_CURRENCY_CODE'
      - 'PREMIUM_CURRENCY_EXCHANGE_RATE'
      - 'PREMIUM_FLOAT_ACCOUNT_TYPE'
      - 'PREMIUM_RATE_PERCENTAGE'
      - 'SERVICE_CHARGE_AMOUNT'
      - 'TOTAL_FEES_AMOUNT'
      - 'WRITE_OFF_WAIVER_INDICATOR'
derived_columns:
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),''))"
  ADDITIONAL_PREMIUM_AMOUNT: 'additional_premium'
  ADMINISTRATION_CHARGES_AMOUNT: 'admin_charges'
  AUTO_ADJUSTED_PREMIUM_AMOUNT: 'auto_adjusted_amount'
  AUTO_ADJUSTMENT_DISCOUNT_LIMIT_AMOUNT: 'auto_adjustment_limit_discount'
  AUTO_ADJUSTMENT_LOADING_LIMIT_AMOUNT: 'auto_adjustment_limit_loading'
  BANK_CHARGES_AMOUNT: 'bank_charges'
  MANUAL_REFUND_AMOUNT: 'refund_amount_manual'
  NET_PREMIUM_IN_PREMIUM_CURRENCY: 'net_premium_in_premium_currency'
  POLICY_PREMIUM_IN_BASE_CURRENCY: 'policy_premium_in_base_currency'
  POLICY_PREMIUM_IN_TRANSACTION_CURRENCY: 'policy_premium_in_transaction_currency'
  POLICY_PREMIUM_VALUE: 'policy_premium_value'
  PREMIUM_AFTER_LOADING_AMOUNT: 'loaded_premium'
  PREMIUM_BEFORE_LOADING_AMOUNT: 'policy_premium_without_loading'
  PREMIUM_CALCULATOR_URN: 'calculator_urn_number'
  PREMIUM_CURRENCY_CODE: 'premium_currency'
  PREMIUM_CURRENCY_EXCHANGE_RATE: 'premium_currency_exchange_rate'
  PREMIUM_FLOAT_ACCOUNT_TYPE: 'opus_float_type'
  PREMIUM_RATE_PERCENTAGE: 'cast(null as varchar)'
  SERVICE_CHARGE_AMOUNT: 'service_charge'
  TOTAL_FEES_AMOUNT: 'total_fees'
  WRITE_OFF_WAIVER_INDICATOR: 'writeoff_waiver_flag'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
