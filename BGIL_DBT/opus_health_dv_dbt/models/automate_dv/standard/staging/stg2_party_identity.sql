-- automate_dv.stage() for SAT_PARTY_IDENTITY, read off central view stitch_v18_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v18_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'DATE_OF_BIRTH'
      - 'FIRST_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'MIDDLE_NAME'
      - 'PARTY_DISPLAY_NAME'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTY_STATUS'
      - 'PARTY_STATUS_REASON'
      - 'PARTY_SUB_TYPE_CODE'
      - 'PARTY_TYPE_CODE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_IDENTITY__AGE, PARTY_IDENTITY__DATE_OF_BIRTH, PARTY_IDENTITY__FIRST_NAME, PARTY_IDENTITY__GENDER_CODE, PARTY_IDENTITY__LAST_NAME, PARTY_IDENTITY__MIDDLE_NAME, PARTY_IDENTITY__PARTY_DISPLAY_NAME, PARTY_IDENTITY__PARTY_FULL_NAME, PARTY_IDENTITY__PARTY_LEGAL_NAME, PARTY_IDENTITY__PARTY_STATUS, PARTY_IDENTITY__PARTY_STATUS_REASON, PARTY_IDENTITY__PARTY_SUB_TYPE_CODE, PARTY_IDENTITY__PARTY_TYPE_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  AGE: 'PARTY_IDENTITY__AGE'
  DATE_OF_BIRTH: 'PARTY_IDENTITY__DATE_OF_BIRTH'
  FIRST_NAME: 'PARTY_IDENTITY__FIRST_NAME'
  GENDER_CODE: 'PARTY_IDENTITY__GENDER_CODE'
  LAST_NAME: 'PARTY_IDENTITY__LAST_NAME'
  MIDDLE_NAME: 'PARTY_IDENTITY__MIDDLE_NAME'
  PARTY_DISPLAY_NAME: 'PARTY_IDENTITY__PARTY_DISPLAY_NAME'
  PARTY_FULL_NAME: 'PARTY_IDENTITY__PARTY_FULL_NAME'
  PARTY_LEGAL_NAME: 'PARTY_IDENTITY__PARTY_LEGAL_NAME'
  PARTY_STATUS: 'PARTY_IDENTITY__PARTY_STATUS'
  PARTY_STATUS_REASON: 'PARTY_IDENTITY__PARTY_STATUS_REASON'
  PARTY_SUB_TYPE_CODE: 'PARTY_IDENTITY__PARTY_SUB_TYPE_CODE'
  PARTY_TYPE_CODE: 'PARTY_IDENTITY__PARTY_TYPE_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v18_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
