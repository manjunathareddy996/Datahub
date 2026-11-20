-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_COVERAGE_PARAMETER (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_mxm__v05_coverage.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__coverage_parameter'
src_pk:
  - 'COVERAGE_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'PARAMETER_REFERENCE_CK'
src_payload:
  - 'BUSINESS_EVENT_CODE'
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
