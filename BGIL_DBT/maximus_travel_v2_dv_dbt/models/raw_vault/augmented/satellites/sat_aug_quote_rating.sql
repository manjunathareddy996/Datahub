{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 sat() for SAT_AUG_QUOTE_RATING.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, QUOTE_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mtv2_aug_sat_aug_quote_rating'
src_pk: 'QUOTE_HKEY'
src_payload:
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
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
