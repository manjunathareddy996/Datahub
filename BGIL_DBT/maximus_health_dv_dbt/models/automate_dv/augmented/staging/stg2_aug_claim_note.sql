-- automate_dv.stage() for SAT_AUG_CLAIM_NOTE, read off central view stitch_v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSIGNED_TO_NAME'
      - 'ASSIGNED_TO_REFERENCE'
      - 'NOTE_SUMMARY'
      - 'NOTE_SEQUENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_NOTE__ASSIGNED_TO_NAME, AUG_CLAIM_NOTE__ASSIGNED_TO_REFERENCE, AUG_CLAIM_NOTE__NOTE_SUMMARY) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  NOTE_SEQUENCE_CK: 'AUG_CLAIM_NOTE__NOTE_SEQUENCE_CK'
  ASSIGNED_TO_NAME: 'AUG_CLAIM_NOTE__ASSIGNED_TO_NAME'
  ASSIGNED_TO_REFERENCE: 'AUG_CLAIM_NOTE__ASSIGNED_TO_REFERENCE'
  NOTE_SUMMARY: 'AUG_CLAIM_NOTE__NOTE_SUMMARY'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
