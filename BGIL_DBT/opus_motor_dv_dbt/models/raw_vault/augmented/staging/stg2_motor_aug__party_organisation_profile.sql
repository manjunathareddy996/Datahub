-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_ORGANISATION_PROFILE, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INTERNAL_INSURER_CODE'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_ORGANISATION_PROFILE__INTERNAL_INSURER_CODE is not null then 'HUB_PARTY|' || PARTY_BK end"
  INTERNAL_INSURER_CODE: 'AUG_PARTY_ORGANISATION_PROFILE__INTERNAL_INSURER_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
