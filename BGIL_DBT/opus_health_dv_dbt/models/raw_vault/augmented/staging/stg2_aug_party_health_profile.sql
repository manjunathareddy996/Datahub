-- automate_dv.stage() for SAT_AUG_PARTY_HEALTH_PROFILE, read off central view stitch_v15_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FAMILY_MEDICAL_HISTORY_DESCRIPTION'
      - 'OBSTETRIC_ABORTION_COUNT'
      - 'OBSTETRIC_GRAVIDA_COUNT'
      - 'OBSTETRIC_LIVE_BIRTH_COUNT'
      - 'OBSTETRIC_PARA_COUNT'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_DESCRIPTION, AUG_PARTY_HEALTH_PROFILE__OBSTETRIC_ABORTION_COUNT, AUG_PARTY_HEALTH_PROFILE__OBSTETRIC_GRAVIDA_COUNT, AUG_PARTY_HEALTH_PROFILE__OBSTETRIC_LIVE_BIRTH_COUNT, AUG_PARTY_HEALTH_PROFILE__OBSTETRIC_PARA_COUNT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  FAMILY_MEDICAL_HISTORY_DESCRIPTION: 'AUG_PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_DESCRIPTION'
  OBSTETRIC_ABORTION_COUNT: 'AUG_PARTY_HEALTH_PROFILE__OBSTETRIC_ABORTION_COUNT'
  OBSTETRIC_GRAVIDA_COUNT: 'AUG_PARTY_HEALTH_PROFILE__OBSTETRIC_GRAVIDA_COUNT'
  OBSTETRIC_LIVE_BIRTH_COUNT: 'AUG_PARTY_HEALTH_PROFILE__OBSTETRIC_LIVE_BIRTH_COUNT'
  OBSTETRIC_PARA_COUNT: 'AUG_PARTY_HEALTH_PROFILE__OBSTETRIC_PARA_COUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
