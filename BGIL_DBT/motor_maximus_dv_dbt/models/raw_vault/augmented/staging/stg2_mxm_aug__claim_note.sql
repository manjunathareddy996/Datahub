-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_NOTE, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSIGNED_TO_USER_NAME'
      - 'ASSIGNED_TO_USER_REFERENCE'
      - 'NOTE_SUMMARY_TEXT'
      - 'NOTE_UPDATED_BY_USER_REFERENCE'
      - 'NOTE_UPDATED_DATE'
      - 'NOTE_SEQUENCE_CK'
      - 'NOTE_AUTHOR_ROLE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_NOTE__ASSIGNED_TO_USER_NAME, AUG_CLAIM_NOTE__ASSIGNED_TO_USER_REFERENCE, AUG_CLAIM_NOTE__NOTE_SUMMARY_TEXT, AUG_CLAIM_NOTE__NOTE_UPDATED_BY_USER_REFERENCE, AUG_CLAIM_NOTE__NOTE_UPDATED_DATE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  NOTE_SEQUENCE_CK: 'AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK'
  NOTE_AUTHOR_ROLE_CK: 'AUG_CLAIM_NOTE__NOTE_AUTHOR_ROLE_CK'
  ASSIGNED_TO_USER_NAME: 'AUG_CLAIM_NOTE__ASSIGNED_TO_USER_NAME'
  ASSIGNED_TO_USER_REFERENCE: 'AUG_CLAIM_NOTE__ASSIGNED_TO_USER_REFERENCE'
  NOTE_SUMMARY_TEXT: 'AUG_CLAIM_NOTE__NOTE_SUMMARY_TEXT'
  NOTE_UPDATED_BY_USER_REFERENCE: 'AUG_CLAIM_NOTE__NOTE_UPDATED_BY_USER_REFERENCE'
  NOTE_UPDATED_DATE: 'AUG_CLAIM_NOTE__NOTE_UPDATED_DATE'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v04_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
