-- automate_dv.stage() for SAT_AUG_PARTY_PAYOUT_PROFILE, read off central view stitch_v16_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SHORT_COLLECTION_RECOVERY_RATE'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_PAYOUT_PROFILE__SHORT_COLLECTION_RECOVERY_RATE is not null then 'HUB_PARTY|' || PARTY_BK end"
  SHORT_COLLECTION_RECOVERY_RATE: 'AUG_PARTY_PAYOUT_PROFILE__SHORT_COLLECTION_RECOVERY_RATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
