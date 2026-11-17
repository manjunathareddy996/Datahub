-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_COVERAGE_MOTOR_ADDON_PARAMS (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_motor__v05_coverage.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__coverage_motor_addon_params'
src_pk: 'COVERAGE_HKEY'
src_cdk:
  - 'ADD_ON_COVERAGE_CODE_CK'
  - 'TYRE_POSITION_CK'
src_payload:
  - 'TYRE_DESCRIPTION'
  - 'TYRE_DETAIL'
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
