-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_CLAIM_STATUS_TRANSITION (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v04_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_status_transition'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'CLAIM_EVENT_CODE_CK'
  - 'EVENT_DATE_CK'
src_payload:
  - 'CLAIM_EVENT_CODE'
  - 'CLAIM_STATUS_CODE'
  - 'CLAIM_SUB_STATUS_CODE'
  - 'DELAY_REASON'
  - 'EVENT_DATE'
  - 'EVENT_DESCRIPTION'
  - 'EVENT_DETAIL_TEXT'
  - 'EVENT_RECORD_CREATED_DATE'
  - 'EVENT_REFERENCE_NUMBER'
  - 'EVENT_REMARKS'
  - 'HISTORY_ENTRY_TYPE'
  - 'PPI_INDICATOR'
  - 'REQUIREMENT_STATUS_AT_EVENT'
  - 'SCRUTINY_STATUS'
  - 'SURVEY_REPORT_STATUS'
  - 'TRANSITION_ACTOR_USER_REFERENCE'
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
