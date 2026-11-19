-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_POLICY_PREMIUM_SUMMARY (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v13_policy.
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_POLICY_PREMIUM_SUMMARY | Premium Calculation Basis | None: emits MODE_OF_PREMIUM_CALCULATION; withheld PREMIUM_CALCULATION_MODE
-- WRITERS MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | SAT_MOTOR_AUG_POLICY_PREMIUM_SUMMARY | Loading Percentage | None: emits LOADING_PERCENTAGE; withheld PERCENTAGE_LOADING_
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__policy_premium_summary'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ADMINISTRATION_CHARGE_AMOUNT'
  - 'ADMINISTRATION_FEE_DESCRIPTION'
  - 'ADMINISTRATIVE_FEE_AMOUNT'
  - 'ADMINISTRATIVE_FEE_WAIVED_INDICATOR'
  - 'BANK_CHARGE_AMOUNT'
  - 'DISCOUNT_PERCENTAGE'
  - 'EXCHANGE_RATE'
  - 'FIXED_CASH_DEPOSIT_SETTLEMENT_INDICATOR'
  - 'LOADED_PREMIUM_AMOUNT'
  - 'LOADING_PERCENTAGE'
  - 'MANUAL_REFUND_AMOUNT'
  - 'MINIMUM_GROSS_PREMIUM'
  - 'NET_PREMIUM_IN_PREMIUM_CURRENCY'
  - 'POLICY_PREMIUM_IN_BASE_CURRENCY'
  - 'POLICY_PREMIUM_IN_TRANSACTION_CURRENCY'
  - 'POLICY_PREMIUM_VALUE'
  - 'PREMIUM_AMOUNT'
  - 'PREMIUM_BEFORE_LOADING_AMOUNT'
  - 'PREMIUM_CALCULATION_BASIS'
  - 'PREMIUM_COLLECTION_AMOUNT'
  - 'PREMIUM_CURRENCY_CODE'
  - 'PREMIUM_CURRENCY_EXCHANGE_RATE'
  - 'PREMIUM_IN_BAHRAINI_DINAR'
  - 'PREMIUM_PAYMENT_MODE'
  - 'THIRD_PARTY_TARIFF_RATE'
  - 'TOTAL_FEES_AMOUNT'
  - 'USER_ENTERED_PREMIUM_AMOUNT'
  - 'USER_OVERRIDDEN_PREMIUM_AMOUNT'
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
