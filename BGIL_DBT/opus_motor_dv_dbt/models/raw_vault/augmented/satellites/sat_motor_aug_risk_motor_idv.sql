-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_RISK_MOTOR_IDV (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v25_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_motor_idv'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'BODY_IDV'
  - 'COMPUTED_IDV_ACCEPTED_INDICATOR'
  - 'CUSTOMER_PROPOSED_IDV'
  - 'IDV_DERIVATION_STATUS'
  - 'IDV_RANGE_LOWER_BOUND'
  - 'IDV_RANGE_UPPER_BOUND'
  - 'MAXIMUM_PERMITTED_IDV'
  - 'MINIMUM_PERMITTED_IDV'
  - 'ORIGINAL_IDV_BEFORE_ADJUSTMENT'
  - 'SYSTEM_IDV_ACCEPTED_INDICATOR'
  - 'VEHICLE_AGE_BAND'
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
