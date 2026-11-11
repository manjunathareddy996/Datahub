-- automate_dv.stage() for SAT_PARTY_HEALTH_PROFILE, read off central view stitch_v18_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v18_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FAMILY_MEDICAL_HISTORY_INDICATOR'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'TOBACCO_CONSUMPTION_DETAIL'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR, PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION, PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL) is not null then 'HUB_PARTY|' || PARTY_BK end"
  FAMILY_MEDICAL_HISTORY_INDICATOR: 'PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION'
  TOBACCO_CONSUMPTION_DETAIL: 'PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v18_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
