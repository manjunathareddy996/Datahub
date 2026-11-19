-- automate_dv.stage() for SAT_PARTY_HEALTH_PROFILE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CURRENT_MEDICATION_DETAIL'
      - 'DISABILITY_INDICATOR'
      - 'DISABILITY_PERCENTAGE'
      - 'HEIGHT'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'WEIGHT'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL, PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR, PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE, PARTY_HEALTH_PROFILE__HEIGHT, PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION, PARTY_HEALTH_PROFILE__WEIGHT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CURRENT_MEDICATION_DETAIL: 'PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL'
  DISABILITY_INDICATOR: 'PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR'
  DISABILITY_PERCENTAGE: 'PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE'
  HEIGHT: 'PARTY_HEALTH_PROFILE__HEIGHT'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION'
  WEIGHT: 'PARTY_HEALTH_PROFILE__WEIGHT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
