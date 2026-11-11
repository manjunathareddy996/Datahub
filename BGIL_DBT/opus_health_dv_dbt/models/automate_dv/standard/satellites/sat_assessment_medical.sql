-- Standard sat() for SAT_ASSESSMENT_MEDICAL (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_v03_assessment.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_assessment_medical'
src_pk: 'ASSESSMENT_HKEY'
src_payload:
  - 'MEDICAL_MANAGEMENT_DATE'
  - 'MEDICAL_MANAGEMENT_TYPE'
  - 'MEDICAL_TEST_TYPE'
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
