-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_PRODUCT_TERMS (parent HUB_PRODUCT, history SCD2), fed whole from central view stitch_motor__v05_coverage.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__product_terms'
src_pk: 'PRODUCT_HKEY'
src_payload:
  - 'APPLICABILITY_FUEL_TYPE'
  - 'APPLICABILITY_VEHICLE_MAKE'
  - 'APPLICABILITY_VEHICLE_MODEL'
  - 'CEILING_KILOMETRE_READING'
  - 'CEILING_RUNNING_HOUR_READING'
  - 'MAXIMUM_VEHICLE_AGE_DAYS'
  - 'MILEAGE_LIMIT'
  - 'MINIMUM_VEHICLE_AGE_DAYS'
  - 'PLAN_EFFECTIVE_FROM_DATE'
  - 'RUNNING_HOUR_LIMIT'
  - 'WARRANTY_TERM'
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
