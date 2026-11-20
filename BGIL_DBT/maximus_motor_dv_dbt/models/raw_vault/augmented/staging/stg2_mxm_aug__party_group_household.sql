-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_GROUP_HOUSEHOLD, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MEMBER_TYPE'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_GROUP_HOUSEHOLD__MEMBER_TYPE is not null then 'HUB_PARTY|' || PARTY_BK end"
  MEMBER_TYPE: 'AUG_PARTY_GROUP_HOUSEHOLD__MEMBER_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
