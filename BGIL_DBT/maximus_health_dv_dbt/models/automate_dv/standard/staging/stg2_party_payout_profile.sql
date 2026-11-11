-- automate_dv.stage() for SAT_PARTY_PAYOUT_PROFILE, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GST_APPLICABLE_INDICATOR'
      - 'TDS_RATE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_PAYOUT_PROFILE__GST_APPLICABLE_INDICATOR, PARTY_PAYOUT_PROFILE__TDS_RATE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  GST_APPLICABLE_INDICATOR: 'PARTY_PAYOUT_PROFILE__GST_APPLICABLE_INDICATOR'
  TDS_RATE: 'PARTY_PAYOUT_PROFILE__TDS_RATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
