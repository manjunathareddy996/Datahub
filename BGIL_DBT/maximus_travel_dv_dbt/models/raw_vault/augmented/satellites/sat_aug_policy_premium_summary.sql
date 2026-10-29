{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL sat() for SAT_AUG_POLICY_PREMIUM_SUMMARY.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, POLICY_HKEY, single-active.

{%- set yaml_metadata -%}
source_model: 'satfeed_mt_aug_sat_aug_policy_premium_summary'
src_pk: 'POLICY_HKEY'
src_payload:
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
