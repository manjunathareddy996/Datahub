-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_RISK_MOTOR_TELEMATICS (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v25_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_motor_telematics'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'APPLICABLE_KILOMETRE_RANGE_FROM'
  - 'APPLICABLE_KILOMETRE_RANGE_TO'
  - 'BONUS_KILOMETRES'
  - 'PLAN_EFFECTIVE_TIME'
  - 'PLAN_EXPIRY_DATE'
  - 'TELEMATICS_OWN_DAMAGE_DISCOUNT_PERCENTAGE'
  - 'TRIP_DESTINATION'
  - 'TRIP_END_DATE'
  - 'TRIP_ORIGIN'
  - 'TRIP_START_DATE'
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
