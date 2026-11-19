-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_RISK_OBJECT_CORE (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v26_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_object_core'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'ISSUANCE_BLOCK_FROM_DATE'
  - 'ISSUANCE_BLOCK_STATUS'
  - 'ISSUANCE_BLOCK_TO_DATE'
  - 'MULTI_VEHICLE_REQUEST_REFERENCE'
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
