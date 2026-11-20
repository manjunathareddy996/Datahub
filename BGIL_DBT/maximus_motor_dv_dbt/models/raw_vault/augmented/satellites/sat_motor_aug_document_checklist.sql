-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_DOCUMENT_CHECKLIST (parent HUB_DOCUMENT, history SCD2), fed whole from central view stitch_mxm__v06_document.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__document_checklist'
src_pk:
  - 'DOCUMENT_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'REQUIRED_DOCUMENT_TYPE_CK'
src_payload:
  - 'ACKNOWLEDGEMENT_RECEIVED_INDICATOR'
  - 'FINAL_DOCUMENT_INDICATOR'
  - 'FIRST_REMINDER_DATE'
  - 'LAST_UPDATED_BY_USER_REFERENCE'
  - 'REQUIREMENT_REMARKS'
  - 'REQUIREMENT_RESPONSE_TEXT'
  - 'REQUIREMENT_SOURCE_NAME'
  - 'REQUIREMENT_STATUS'
  - 'SECOND_REMINDER_DATE'
  - 'THIRD_REMINDER_DATE'
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
