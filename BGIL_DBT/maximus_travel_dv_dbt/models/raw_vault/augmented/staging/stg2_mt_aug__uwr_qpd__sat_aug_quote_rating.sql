{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_QUOTE_RATING from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 51 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'stg_mt__uwr_qpd'
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
  QUOTE_BK: "nullif(trim(case when coalesce(nullif(trim(policy_quote_number),'')) is not null then nullif(trim(policy_quote_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when coalesce(nullif(trim(policy_quote_number),'')) is not null then nullif(trim(policy_quote_number), '') end),''))"
  ADDITIONAL_PREMIUM_AMOUNT: 'cast(null as varchar)'
  ADMINISTRATION_CHARGES_AMOUNT: 'cast(null as varchar)'
  AMOUNT_RECEIVED: 'cast(null as varchar)'
  AUTO_ADJUSTED_PREMIUM_AMOUNT: 'cast(null as varchar)'
  AUTO_ADJUSTMENT_DISCOUNT_LIMIT_AMOUNT: 'cast(null as varchar)'
  AUTO_ADJUSTMENT_LOADING_LIMIT_AMOUNT: 'cast(null as varchar)'
  BANK_CHARGES_AMOUNT: 'cast(null as varchar)'
  CESS_AMOUNT: 'cast(null as varchar)'
  CGST_AMOUNT: 'cast(null as varchar)'
  COMMISSION_AMOUNT: 'commission'
  COMMISSION_CHANGE_EFFECTIVE_DATE: 'cast(null as varchar)'
  COVER_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'cast(null as varchar)'
  ELAPSED_PERIOD_PREMIUM_AMOUNT: 'cast(null as varchar)'
  GST_BIFURCATION: 'cast(null as varchar)'
  GST_TDS_AMOUNT: 'cast(null as varchar)'
  GST_TYPE: 'cast(null as varchar)'
  IGST_AMOUNT: 'cast(null as varchar)'
  MANUAL_REFUND_AMOUNT: 'cast(null as varchar)'
  NET_PREMIUM_IN_PREMIUM_CURRENCY: 'cast(null as varchar)'
  NEW_PREMIUM_INDICATOR: 'new_prem_indicator'
  POLICY_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE: 'cast(null as varchar)'
  POLICY_PREMIUM_IN_BASE_CURRENCY: 'cast(null as varchar)'
  POLICY_PREMIUM_IN_TRANSACTION_CURRENCY: 'cast(null as varchar)'
  POLICY_PREMIUM_VALUE: 'cast(null as varchar)'
  PREMIUM_ADJUSTMENT_AMOUNT: 'cast(null as varchar)'
  PREMIUM_ADJUSTMENT_TYPE: 'cast(null as varchar)'
  PREMIUM_AFTER_LOADING_AMOUNT: 'cast(null as varchar)'
  PREMIUM_AMOUNT_IN_BHD: 'cast(null as varchar)'
  PREMIUM_BEFORE_LOADING_AMOUNT: 'cast(null as varchar)'
  PREMIUM_CALCULATOR_URN: 'cast(null as varchar)'
  PREMIUM_COLLECTED_AMOUNT: 'cast(null as varchar)'
  PREMIUM_CURRENCY_CODE: 'cast(null as varchar)'
  PREMIUM_CURRENCY_EXCHANGE_RATE: 'cast(null as varchar)'
  PREMIUM_FLOAT_ACCOUNT_TYPE: 'cast(null as varchar)'
  PRIVILEGE_SCHEME_CODE: 'strprivilege_code'
  REFUND_AMOUNT: 'cast(null as varchar)'
  RETAINED_ADMIN_CHARGES_AMOUNT: 'cast(null as varchar)'
  RISK_LOADING_TYPE: 'cast(null as varchar)'
  RISK_PREMIUM_IN_BASE_CURRENCY: 'cast(null as varchar)'
  RISK_PREMIUM_IN_TRANSACTION_CURRENCY: 'cast(null as varchar)'
  SERVICE_CHARGE_AMOUNT: 'cast(null as varchar)'
  SGST_AMOUNT: 'cast(null as varchar)'
  STAMP_DUTY_RECEIPT_NUMBER: 'cast(null as varchar)'
  TOTAL_FEES_AMOUNT: 'cast(null as varchar)'
  TOTAL_PREMIUM_COLLECTED: 'cast(null as varchar)'
  TOTAL_PREMIUM_DUE: 'cast(null as varchar)'
  TOTAL_TAX_AMOUNT: 'cast(null as varchar)'
  TRAVELLING_COMPANION_DISCOUNT_AMOUNT: 'cast(null as varchar)'
  UNEXPIRED_PERIOD_PREMIUM_AMOUNT: 'cast(null as varchar)'
  UTGST_AMOUNT: 'cast(null as varchar)'
  WRITE_OFF_WAIVER_INDICATOR: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
