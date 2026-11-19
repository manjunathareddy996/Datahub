-- automate_dv.stage() for SAT_MOTOR_AUG_COMMON_COMMUNICATION_PREFERENCE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMUNICATION_AND_LANGUAGE_PREFERENCE_TEXT'
      - 'PREFERRED_ALERT_CHANNEL_CODE'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_COMMON_COMMUNICATION_PREFERENCE__COMMUNICATION_AND_LANGUAGE_PREFERENCE_TEXT, AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  COMMUNICATION_AND_LANGUAGE_PREFERENCE_TEXT: 'AUG_COMMON_COMMUNICATION_PREFERENCE__COMMUNICATION_AND_LANGUAGE_PREFERENCE_TEXT'
  PREFERRED_ALERT_CHANNEL_CODE: 'AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
