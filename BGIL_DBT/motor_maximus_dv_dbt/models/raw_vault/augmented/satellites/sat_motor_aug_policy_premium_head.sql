-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_POLICY_PREMIUM_HEAD (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v07_financial_transaction.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__policy_premium_head'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'PREMIUM_HEAD_CODE_CK'
  - 'COVERAGE_REFERENCE_CK'
  - 'SECTION_CK'
  - 'ADJUSTED_INDICATOR_CK'
src_payload:
  - 'EARNED_HEAD_PREMIUM'
  - 'EXCHANGE_RATE_APPLIED'
  - 'EXPIRING_PREMIUM_AMOUNT'
  - 'FIXED_PREMIUM_SYSTEM_CODE'
  - 'GROSS_HEAD_PREMIUM'
  - 'NET_HEAD_PREMIUM_IN_BASE_CURRENCY'
  - 'PREMIUM_ADJUSTMENT_AMOUNT'
  - 'PREMIUM_ADJUSTMENT_TYPE'
  - 'PREMIUM_RATE_APPLIED'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
