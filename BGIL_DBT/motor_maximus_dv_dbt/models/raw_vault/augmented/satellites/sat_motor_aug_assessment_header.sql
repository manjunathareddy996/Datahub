-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_ASSESSMENT_HEADER (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_mxm__v01_assessment.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__assessment_header'
src_pk:
  - 'ASSESSMENT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'AI_ASSESSMENT_STATUS'
  - 'ASSESSMENT_END_TIME'
  - 'ASSESSMENT_NATURE'
  - 'ASSESSMENT_REPORT_REFERENCE'
  - 'ASSESSMENT_REVIEW_REMARKS'
  - 'ASSESSMENT_SCALE'
  - 'ASSESSMENT_START_TIME'
  - 'CDC_REFERENCE_NUMBER'
  - 'CDC_STATUS'
  - 'DEPUTATION_CONFIRMATION_DATE'
  - 'INSPECTION_CONDUCTED_INDICATOR'
  - 'INSPECTION_OTHER_REMARKS'
  - 'PERSONAL_ACCIDENT_ASSESSMENT_ACTION'
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
