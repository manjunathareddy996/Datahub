-- Standard sat() for SAT_RISK_MOTOR_TELEMATICS (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v25_risk_object.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor__risk_motor_telematics'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'DRIVING_BEHAVIOUR_SCORE'
  - 'INCLUDED_KILOMETRES'
  - 'ODOMETER_READING'
  - 'PLAN_EFFECTIVE_DATE'
  - 'SCORE_DATE'
  - 'TOP_UP_KILOMETRE_SLAB'
  - 'USAGE_BASED_PLAN_TYPE'
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
