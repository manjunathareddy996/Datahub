-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_POLICY_PREMIUM_HEAD (parent HUB_POLICY, history SCD2), fed whole from central view stitch_motor__v14_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__policy_premium_head'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'PREMIUM_HEAD_CODE_CK'
  - 'COVERAGE_REFERENCE_CK'
  - 'SECTION_CK'
  - 'ADJUSTED_INDICATOR_CK'
src_payload:
  - 'ADJUSTMENT_REMARKS'
  - 'DISCOUNT_PERCENTAGE'
  - 'HEAD_PREMIUM_RATE'
  - 'LOADING_PERCENTAGE'
  - 'MINIMUM_HEAD_PREMIUM'
  - 'PREMIUM_ADJUSTMENT_AMOUNT'
  - 'PREMIUM_RATE'
  - 'SECTION_APPLICABLE_INDICATOR'
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
