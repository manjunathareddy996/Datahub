-- automate_dv.stage() for SAT_MOTOR_AUG_COMMON_CLASSIFICATION, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OVERALL_RATING_GRADE'
      - 'PROFILE_CODE'
      - 'REFERENCE_CODE'
      - 'USER_TYPE_CODE'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_COMMON_CLASSIFICATION__OVERALL_RATING_GRADE, AUG_COMMON_CLASSIFICATION__PROFILE_CODE, AUG_COMMON_CLASSIFICATION__REFERENCE_CODE, AUG_COMMON_CLASSIFICATION__USER_TYPE_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  OVERALL_RATING_GRADE: 'AUG_COMMON_CLASSIFICATION__OVERALL_RATING_GRADE'
  PROFILE_CODE: 'AUG_COMMON_CLASSIFICATION__PROFILE_CODE'
  REFERENCE_CODE: 'AUG_COMMON_CLASSIFICATION__REFERENCE_CODE'
  USER_TYPE_CODE: 'AUG_COMMON_CLASSIFICATION__USER_TYPE_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
