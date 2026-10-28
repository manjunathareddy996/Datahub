{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_POLICY_PREMIUM_SUMMARY from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 21 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_rskp_sp_pv'
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
  ADDITIONAL_PREMIUM_AMOUNT: 'cast(null as varchar)'
  ADMINISTRATION_CHARGES_AMOUNT: 'cast(null as varchar)'
  AUTO_ADJUSTED_PREMIUM_AMOUNT: 'cast(null as varchar)'
  AUTO_ADJUSTMENT_DISCOUNT_LIMIT_AMOUNT: 'cast(null as varchar)'
  AUTO_ADJUSTMENT_LOADING_LIMIT_AMOUNT: 'cast(null as varchar)'
  BANK_CHARGES_AMOUNT: 'cast(null as varchar)'
  MANUAL_REFUND_AMOUNT: 'cast(null as varchar)'
  NET_PREMIUM_IN_PREMIUM_CURRENCY: 'cast(null as varchar)'
  POLICY_PREMIUM_IN_BASE_CURRENCY: 'cast(null as varchar)'
  POLICY_PREMIUM_IN_TRANSACTION_CURRENCY: 'cast(null as varchar)'
  POLICY_PREMIUM_VALUE: 'cast(null as varchar)'
  PREMIUM_AFTER_LOADING_AMOUNT: 'cast(null as varchar)'
  PREMIUM_BEFORE_LOADING_AMOUNT: 'cast(null as varchar)'
  PREMIUM_CALCULATOR_URN: 'cast(null as varchar)'
  PREMIUM_CURRENCY_CODE: 'cast(null as varchar)'
  PREMIUM_CURRENCY_EXCHANGE_RATE: 'cast(null as varchar)'
  PREMIUM_FLOAT_ACCOUNT_TYPE: 'cast(null as varchar)'
  PREMIUM_RATE_PERCENTAGE: 'rate_percentage'
  SERVICE_CHARGE_AMOUNT: 'cast(null as varchar)'
  TOTAL_FEES_AMOUNT: 'cast(null as varchar)'
  WRITE_OFF_WAIVER_INDICATOR: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
