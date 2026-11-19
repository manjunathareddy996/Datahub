-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_RISK_MOTOR_FITMENTS (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v14_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_motor_fitments'
src_pk: 'RISK_OBJECT_HKEY'
src_cdk:
  - 'FITMENT_TYPE_CK'
  - 'SEQUENCE_CK'
src_payload:
  - 'SYSTEM_CALCULATED_FITMENT_VALUE'
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
