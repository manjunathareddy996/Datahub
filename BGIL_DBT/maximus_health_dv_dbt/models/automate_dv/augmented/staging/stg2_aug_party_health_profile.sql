-- automate_dv.stage() for SAT_AUG_PARTY_HEALTH_PROFILE, read off central view stitch_v12_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v12_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BEER_UNITS_PER_WEEK'
      - 'DISABILITY_BODY_LOCATION'
      - 'ICD_DIAGNOSIS_CODE'
      - 'SPIRITS_UNITS_PER_WEEK'
      - 'SURGERY_HISTORY_DESCRIPTION'
      - 'WINE_UNITS_PER_WEEK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_HEALTH_PROFILE__BEER_UNITS_PER_WEEK, AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION, AUG_PARTY_HEALTH_PROFILE__ICD_DIAGNOSIS_CODE, AUG_PARTY_HEALTH_PROFILE__SPIRITS_UNITS_PER_WEEK, AUG_PARTY_HEALTH_PROFILE__SURGERY_HISTORY_DESCRIPTION, AUG_PARTY_HEALTH_PROFILE__WINE_UNITS_PER_WEEK) is not null then 'HUB_PARTY|' || PARTY_BK end"
  BEER_UNITS_PER_WEEK: 'AUG_PARTY_HEALTH_PROFILE__BEER_UNITS_PER_WEEK'
  DISABILITY_BODY_LOCATION: 'AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION'
  ICD_DIAGNOSIS_CODE: 'AUG_PARTY_HEALTH_PROFILE__ICD_DIAGNOSIS_CODE'
  SPIRITS_UNITS_PER_WEEK: 'AUG_PARTY_HEALTH_PROFILE__SPIRITS_UNITS_PER_WEEK'
  SURGERY_HISTORY_DESCRIPTION: 'AUG_PARTY_HEALTH_PROFILE__SURGERY_HISTORY_DESCRIPTION'
  WINE_UNITS_PER_WEEK: 'AUG_PARTY_HEALTH_PROFILE__WINE_UNITS_PER_WEEK'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v12_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
