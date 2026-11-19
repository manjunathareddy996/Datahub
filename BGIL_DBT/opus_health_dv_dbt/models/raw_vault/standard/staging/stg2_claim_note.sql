-- automate_dv.stage() for SAT_CLAIM_NOTE, read off central view stitch_v06_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FOLLOW_UP_REQUIRED_INDICATOR'
      - 'NOTE_TEXT'
      - 'NOTE_SEQUENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR, CLAIM_NOTE__NOTE_TEXT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  NOTE_SEQUENCE_CK: 'CLAIM_NOTE__NOTE_SEQUENCE_CK'
  FOLLOW_UP_REQUIRED_INDICATOR: 'CLAIM_NOTE__FOLLOW_UP_REQUIRED_INDICATOR'
  NOTE_TEXT: 'CLAIM_NOTE__NOTE_TEXT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
