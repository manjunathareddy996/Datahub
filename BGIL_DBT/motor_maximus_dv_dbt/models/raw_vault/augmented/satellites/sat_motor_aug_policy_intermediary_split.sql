-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_POLICY_INTERMEDIARY_SPLIT (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v12_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__policy_intermediary_split'
src_pk:
  - 'POLICY_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'INTERMEDIARY_REFERENCE_CK'
src_payload:
  - 'COMMISSION_DISCOUNT_AMOUNT'
  - 'COMMISSION_LOADING_AMOUNT'
  - 'LINE_OF_BUSINESS_COMMISSION_APPLICABLE_INDICATOR'
  - 'LINE_OF_BUSINESS_COMMISSION_IMPACT_AMOUNT'
  - 'SERVICE_CHARGE_AMOUNT'
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
