-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_COVERAGE_PARAMETER (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_v12_coverage.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_coverage_parameter'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'PARAMETER_REFERENCE'
  - 'PARAMETER_VALUE'
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
