-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_IDENTITY, read off central view stitch_mxm__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE_BAND'
      - 'ASSOCIATED_INSTITUTION_NAME'
      - 'OTHER_PARTY_DETAIL_TEXT'
      - 'PARTY_DESCRIPTION_TEXT'
      - 'PARTY_RECORD_END_DATE'
      - 'PARTY_RECORD_LAST_MODIFIED_DATE'
      - 'PERSONAL_DETAIL_TEXT'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_IDENTITY__AGE_BAND, AUG_PARTY_IDENTITY__ASSOCIATED_INSTITUTION_NAME, AUG_PARTY_IDENTITY__OTHER_PARTY_DETAIL_TEXT, AUG_PARTY_IDENTITY__PARTY_DESCRIPTION_TEXT, AUG_PARTY_IDENTITY__PARTY_RECORD_END_DATE, AUG_PARTY_IDENTITY__PARTY_RECORD_LAST_MODIFIED_DATE, AUG_PARTY_IDENTITY__PERSONAL_DETAIL_TEXT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  AGE_BAND: 'AUG_PARTY_IDENTITY__AGE_BAND'
  ASSOCIATED_INSTITUTION_NAME: 'AUG_PARTY_IDENTITY__ASSOCIATED_INSTITUTION_NAME'
  OTHER_PARTY_DETAIL_TEXT: 'AUG_PARTY_IDENTITY__OTHER_PARTY_DETAIL_TEXT'
  PARTY_DESCRIPTION_TEXT: 'AUG_PARTY_IDENTITY__PARTY_DESCRIPTION_TEXT'
  PARTY_RECORD_END_DATE: 'AUG_PARTY_IDENTITY__PARTY_RECORD_END_DATE'
  PARTY_RECORD_LAST_MODIFIED_DATE: 'AUG_PARTY_IDENTITY__PARTY_RECORD_LAST_MODIFIED_DATE'
  PERSONAL_DETAIL_TEXT: 'AUG_PARTY_IDENTITY__PERSONAL_DETAIL_TEXT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
