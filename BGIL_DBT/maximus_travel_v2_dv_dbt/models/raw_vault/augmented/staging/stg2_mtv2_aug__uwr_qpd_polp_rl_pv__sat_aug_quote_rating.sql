{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_QUOTE_RATING from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 51 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_qpd_polp_rl_pv'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_QUOTE_RATING:
    is_hashdiff: true
    columns:
      - 'ADDITIONAL_PREMIUM_AMOUNT'
      - 'ADMINISTRATION_CHARGES_AMOUNT'
      - 'AMOUNT_RECEIVED'
      - 'AUTO_ADJUSTED_PREMIUM_AMOUNT'
      - 'AUTO_ADJUSTMENT_DISCOUNT_LIMIT_AMOUNT'
      - 'AUTO_ADJUSTMENT_LOADING_LIMIT_AMOUNT'
      - 'BANK_CHARGES_AMOUNT'
      - 'CESS_AMOUNT'
      - 'CGST_AMOUNT'
      - 'COMMISSION_AMOUNT'
      - 'COMMISSION_CHANGE_EFFECTIVE_DATE'
      - 'COVER_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE'
      - 'ELAPSED_PERIOD_PREMIUM_AMOUNT'
      - 'GST_BIFURCATION'
      - 'GST_TDS_AMOUNT'
      - 'GST_TYPE'
      - 'IGST_AMOUNT'
      - 'MANUAL_REFUND_AMOUNT'
      - 'NET_PREMIUM_IN_PREMIUM_CURRENCY'
      - 'NEW_PREMIUM_INDICATOR'
      - 'POLICY_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE'
      - 'POLICY_PREMIUM_IN_BASE_CURRENCY'
      - 'POLICY_PREMIUM_IN_TRANSACTION_CURRENCY'
      - 'POLICY_PREMIUM_VALUE'
      - 'PREMIUM_ADJUSTMENT_AMOUNT'
      - 'PREMIUM_ADJUSTMENT_TYPE'
      - 'PREMIUM_AFTER_LOADING_AMOUNT'
      - 'PREMIUM_AMOUNT_IN_BHD'
      - 'PREMIUM_BEFORE_LOADING_AMOUNT'
      - 'PREMIUM_CALCULATOR_URN'
      - 'PREMIUM_COLLECTED_AMOUNT'
      - 'PREMIUM_CURRENCY_CODE'
      - 'PREMIUM_CURRENCY_EXCHANGE_RATE'
      - 'PREMIUM_FLOAT_ACCOUNT_TYPE'
      - 'PRIVILEGE_SCHEME_CODE'
      - 'REFUND_AMOUNT'
      - 'RETAINED_ADMIN_CHARGES_AMOUNT'
      - 'RISK_LOADING_TYPE'
      - 'RISK_PREMIUM_IN_BASE_CURRENCY'
      - 'RISK_PREMIUM_IN_TRANSACTION_CURRENCY'
      - 'SERVICE_CHARGE_AMOUNT'
      - 'SGST_AMOUNT'
      - 'STAMP_DUTY_RECEIPT_NUMBER'
      - 'TOTAL_FEES_AMOUNT'
      - 'TOTAL_PREMIUM_COLLECTED'
      - 'TOTAL_PREMIUM_DUE'
      - 'TOTAL_TAX_AMOUNT'
      - 'TRAVELLING_COMPANION_DISCOUNT_AMOUNT'
      - 'UNEXPIRED_PERIOD_PREMIUM_AMOUNT'
      - 'UTGST_AMOUNT'
      - 'WRITE_OFF_WAIVER_INDICATOR'
derived_columns:
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),''))"
  ADDITIONAL_PREMIUM_AMOUNT: 'additional_premium'
  ADMINISTRATION_CHARGES_AMOUNT: 'admin_charges'
  AMOUNT_RECEIVED: 'amount_recevied'
  AUTO_ADJUSTED_PREMIUM_AMOUNT: 'auto_adjusted_amount'
  AUTO_ADJUSTMENT_DISCOUNT_LIMIT_AMOUNT: 'auto_adjustment_limit_discount'
  AUTO_ADJUSTMENT_LOADING_LIMIT_AMOUNT: 'auto_adjustment_limit_loading'
  BANK_CHARGES_AMOUNT: 'bank_charges'
  CESS_AMOUNT: 'cess'
  CGST_AMOUNT: 'cgst_amount'
  COMMISSION_AMOUNT: 'cast(null as varchar)'
  COMMISSION_CHANGE_EFFECTIVE_DATE: 'date_for_commission_change'
  COVER_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'cover_level_transaction_currency_for_sum_insured'
  ELAPSED_PERIOD_PREMIUM_AMOUNT: 'calculated_amount_for_elapsed_period'
  GST_BIFURCATION: 'gst_bifurcation'
  GST_TDS_AMOUNT: 'gst_tds'
  GST_TYPE: 'gst_type'
  IGST_AMOUNT: 'igst_amount'
  MANUAL_REFUND_AMOUNT: 'refund_amount_manual'
  NET_PREMIUM_IN_PREMIUM_CURRENCY: 'net_premium_in_premium_currency'
  NEW_PREMIUM_INDICATOR: 'cast(null as varchar)'
  POLICY_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'policy_level_transaction_currency_for_sum_insured'
  POLICY_PREMIUM_IN_BASE_CURRENCY: 'policy_premium_in_base_currency'
  POLICY_PREMIUM_IN_TRANSACTION_CURRENCY: 'policy_premium_in_transaction_currency'
  POLICY_PREMIUM_VALUE: 'policy_premium_value'
  PREMIUM_ADJUSTMENT_AMOUNT: 'cast(null as varchar)'
  PREMIUM_ADJUSTMENT_TYPE: 'cast(null as varchar)'
  PREMIUM_AFTER_LOADING_AMOUNT: 'loaded_premium'
  PREMIUM_AMOUNT_IN_BHD: 'cast(null as varchar)'
  PREMIUM_BEFORE_LOADING_AMOUNT: 'policy_premium_without_loading'
  PREMIUM_CALCULATOR_URN: 'calculator_urn_number'
  PREMIUM_COLLECTED_AMOUNT: 'cast(null as varchar)'
  PREMIUM_CURRENCY_CODE: 'premium_currency'
  PREMIUM_CURRENCY_EXCHANGE_RATE: 'premium_currency_exchange_rate'
  PREMIUM_FLOAT_ACCOUNT_TYPE: 'opus_float_type'
  PRIVILEGE_SCHEME_CODE: 'cast(null as varchar)'
  REFUND_AMOUNT: 'refund_amount'
  RETAINED_ADMIN_CHARGES_AMOUNT: 'retained_admin_charges'
  RISK_LOADING_TYPE: 'cast(null as varchar)'
  RISK_PREMIUM_IN_BASE_CURRENCY: 'cast(null as varchar)'
  RISK_PREMIUM_IN_TRANSACTION_CURRENCY: 'cast(null as varchar)'
  SERVICE_CHARGE_AMOUNT: 'service_charge'
  SGST_AMOUNT: 'sgst_amount'
  STAMP_DUTY_RECEIPT_NUMBER: 'stamp_receipt_no'
  TOTAL_FEES_AMOUNT: 'total_fees'
  TOTAL_PREMIUM_COLLECTED: 'premium_collected'
  TOTAL_PREMIUM_DUE: 'cast(null as varchar)'
  TOTAL_TAX_AMOUNT: 'total_taxes'
  TRAVELLING_COMPANION_DISCOUNT_AMOUNT: 'cast(null as varchar)'
  UNEXPIRED_PERIOD_PREMIUM_AMOUNT: 'calculated_amount_for_remaining_period'
  UTGST_AMOUNT: 'utgst_amount'
  WRITE_OFF_WAIVER_INDICATOR: 'writeoff_waiver_flag'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
