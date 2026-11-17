-- Standard sat() for SAT_RISK_MOTOR_VERIFICATION (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v15_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_motor_verification'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'VAHAN_CHECK_STATUS'
  - 'VEHICLE_VERIFICATION_REFERENCE'
  - 'VERIFICATION_REMARKS'
  - 'VERIFICATION_REQUEST_NUMBER'
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
