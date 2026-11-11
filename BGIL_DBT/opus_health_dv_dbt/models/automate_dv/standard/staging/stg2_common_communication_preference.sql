-- automate_dv.stage() for SAT_COMMON_COMMUNICATION_PREFERENCE, read off central view stitch_v23_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v23_policy'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREFERRED_CHANNEL_CODE'
derived_columns:
  PARTY_NK: "case when COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE is not null then 'HUB_PARTY|' || PARTY_BK end"
  PREFERRED_CHANNEL_CODE: 'COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v23_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
