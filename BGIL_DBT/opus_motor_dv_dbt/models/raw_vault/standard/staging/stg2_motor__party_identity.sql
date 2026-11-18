-- automate_dv.stage() for SAT_PARTY_IDENTITY, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
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
      - 'NAME_SUFFIX'
      - 'PARTY_DISPLAY_NAME'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTY_SUB_TYPE_CODE'
      - 'PARTY_TYPE_CODE'
      - 'SALUTATION'
      - 'TITLE_CODE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_IDENTITY__AGE, PARTY_IDENTITY__DATE_OF_BIRTH, PARTY_IDENTITY__FIRST_NAME, PARTY_IDENTITY__GENDER_CODE, PARTY_IDENTITY__LAST_NAME, PARTY_IDENTITY__MIDDLE_NAME, PARTY_IDENTITY__NAME_SUFFIX, PARTY_IDENTITY__PARTY_DISPLAY_NAME, PARTY_IDENTITY__PARTY_FULL_NAME, PARTY_IDENTITY__PARTY_LEGAL_NAME, PARTY_IDENTITY__PARTY_SUB_TYPE_CODE, PARTY_IDENTITY__PARTY_TYPE_CODE, PARTY_IDENTITY__SALUTATION, PARTY_IDENTITY__TITLE_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  AGE: 'PARTY_IDENTITY__AGE'
  DATE_OF_BIRTH: 'PARTY_IDENTITY__DATE_OF_BIRTH'
  FIRST_NAME: 'PARTY_IDENTITY__FIRST_NAME'
  GENDER_CODE: 'PARTY_IDENTITY__GENDER_CODE'
  LAST_NAME: 'PARTY_IDENTITY__LAST_NAME'
  MIDDLE_NAME: 'PARTY_IDENTITY__MIDDLE_NAME'
  NAME_SUFFIX: 'PARTY_IDENTITY__NAME_SUFFIX'
  PARTY_DISPLAY_NAME: 'PARTY_IDENTITY__PARTY_DISPLAY_NAME'
  PARTY_FULL_NAME: 'PARTY_IDENTITY__PARTY_FULL_NAME'
  PARTY_LEGAL_NAME: 'PARTY_IDENTITY__PARTY_LEGAL_NAME'
  PARTY_SUB_TYPE_CODE: 'PARTY_IDENTITY__PARTY_SUB_TYPE_CODE'
  PARTY_TYPE_CODE: 'PARTY_IDENTITY__PARTY_TYPE_CODE'
  SALUTATION: 'PARTY_IDENTITY__SALUTATION'
  TITLE_CODE: 'PARTY_IDENTITY__TITLE_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
