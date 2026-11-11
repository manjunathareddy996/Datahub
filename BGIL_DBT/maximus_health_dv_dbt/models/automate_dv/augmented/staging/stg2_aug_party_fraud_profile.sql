-- automate_dv.stage() for SAT_AUG_PARTY_FRAUD_PROFILE, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NEGATIVE_LIST_DETAILS'
      - 'NON_DISCLOSURE_ACTION_INITIATED_INDICATOR'
      - 'PARTY_BLOCK_STATUS'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_FRAUD_PROFILE__NEGATIVE_LIST_DETAILS, AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR, AUG_PARTY_FRAUD_PROFILE__PARTY_BLOCK_STATUS) is not null then 'HUB_PARTY|' || PARTY_BK end"
  NEGATIVE_LIST_DETAILS: 'AUG_PARTY_FRAUD_PROFILE__NEGATIVE_LIST_DETAILS'
  NON_DISCLOSURE_ACTION_INITIATED_INDICATOR: 'AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR'
  PARTY_BLOCK_STATUS: 'AUG_PARTY_FRAUD_PROFILE__PARTY_BLOCK_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
