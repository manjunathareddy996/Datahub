-- automate_dv.stage() for SAT_COMMON_COMMUNICATION_PREFERENCE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GO_GREEN_OPT_IN_INDICATOR'
      - 'PREFERRED_CHANNEL_CODE'
      - 'PREFERRED_LANGUAGE_CODE'
derived_columns:
  PARTY_NK: "case when coalesce(COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR, COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE, COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  GO_GREEN_OPT_IN_INDICATOR: 'COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR'
  PREFERRED_CHANNEL_CODE: 'COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE'
  PREFERRED_LANGUAGE_CODE: 'COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
