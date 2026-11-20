-- automate_dv.stage() for SAT_CLAIM_NOTE, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NOTE_AUTHOR_REFERENCE'
      - 'NOTE_CATEGORY'
      - 'NOTE_DATE'
      - 'NOTE_TEXT'
      - 'NOTE_TYPE'
      - 'NOTE_SEQUENCE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_NOTE__NOTE_AUTHOR_REFERENCE, CLAIM_NOTE__NOTE_CATEGORY, CLAIM_NOTE__NOTE_DATE, CLAIM_NOTE__NOTE_TEXT, CLAIM_NOTE__NOTE_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  NOTE_SEQUENCE_CK: 'CLAIM_NOTE__NOTE_SEQUENCE_CK'
  NOTE_AUTHOR_REFERENCE: 'CLAIM_NOTE__NOTE_AUTHOR_REFERENCE'
  NOTE_CATEGORY: 'CLAIM_NOTE__NOTE_CATEGORY'
  NOTE_DATE: 'CLAIM_NOTE__NOTE_DATE'
  NOTE_TEXT: 'CLAIM_NOTE__NOTE_TEXT'
  NOTE_TYPE: 'CLAIM_NOTE__NOTE_TYPE'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v04_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
