-- Standard sat() for SAT_ASSESSMENT_SURVEY (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_mxm__v01_assessment.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | SAT_ASSESSMENT_SURVEY | Survey Type | survey: emits SURVEY_TYPE; withheld TYPE_OF_SURVEY
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__assessment_survey'
src_pk: 'ASSESSMENT_HKEY'
src_payload:
  - 'FINAL_SURVEY_INDICATOR'
  - 'FINAL_VISIT_DATE'
  - 'NUMBER_OF_VISITS'
  - 'SPOT_SURVEY_INDICATOR'
  - 'SURVEY_ALLOCATION_DATE'
  - 'SURVEY_TYPE'
  - 'WORK_APPROVAL_DATE'
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
