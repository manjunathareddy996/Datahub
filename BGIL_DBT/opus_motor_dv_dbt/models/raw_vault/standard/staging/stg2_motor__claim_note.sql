-- automate_dv.stage() for SAT_CLAIM_NOTE, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NOTE_TEXT'
      - 'NOTE_SEQUENCE'
derived_columns:
  CLAIM_NK: "case when CLAIM_NOTE__NOTE_TEXT is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  NOTE_SEQUENCE: 'CLAIM_NOTE__NOTE_SEQUENCE_CK'
  NOTE_TEXT: 'CLAIM_NOTE__NOTE_TEXT'
  LOAD_DATETIME: 'CLAIM_NOTE__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
