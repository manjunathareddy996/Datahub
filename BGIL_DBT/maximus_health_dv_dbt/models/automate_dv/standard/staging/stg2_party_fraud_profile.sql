-- automate_dv.stage() for SAT_PARTY_FRAUD_PROFILE, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NEGATIVE_LIST_INDICATOR'
      - 'NEGATIVE_LIST_REASON'
      - 'WATCH_START_DATE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_FRAUD_PROFILE__NEGATIVE_LIST_INDICATOR, PARTY_FRAUD_PROFILE__NEGATIVE_LIST_REASON, PARTY_FRAUD_PROFILE__WATCH_START_DATE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  NEGATIVE_LIST_INDICATOR: 'PARTY_FRAUD_PROFILE__NEGATIVE_LIST_INDICATOR'
  NEGATIVE_LIST_REASON: 'PARTY_FRAUD_PROFILE__NEGATIVE_LIST_REASON'
  WATCH_START_DATE: 'PARTY_FRAUD_PROFILE__WATCH_START_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
