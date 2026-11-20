-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_RISK_OBJECT_OWNERSHIP_HISTORY (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v12_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__risk_object_ownership_history'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'OWNER_SEQUENCE_CK'
src_payload:
  - 'TRANSFEREE_NAME'
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
