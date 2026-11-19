-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_ASSESSMENT_REINSPECTION (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_mxm__v09_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__assessment_reinspection'
src_pk: 'ASSESSMENT_HKEY'
src_payload:
  - 'RE_INSPECTION_CONDUCTED_INDICATOR'
  - 'RE_INSPECTION_DELAY_DAYS'
  - 'RE_INSPECTION_INDICATOR'
  - 'RE_INSPECTION_OTHER_REMARKS'
  - 'RE_INSPECTION_REMARKS'
  - 'RE_INSPECTION_REQUESTED_INDICATOR'
  - 'RE_INSPECTION_REQUEST_DATE'
  - 'RE_INSPECTION_STATUS'
  - 'RE_INSPECTION_SURVEY_DATE'
  - 'RE_INSPECTION_SURVEY_REMARKS'
  - 'RE_INSPECTION_SURVEY_TIME'
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
