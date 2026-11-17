-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_COVERAGE_MOTOR_LAID_UP (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_motor__v05_coverage.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__coverage_motor_laid_up'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'LAID_UP_END_DATE'
  - 'LAID_UP_START_DATE'
  - 'LAID_UP_SUB_TYPE'
  - 'LAID_UP_TYPE'
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
