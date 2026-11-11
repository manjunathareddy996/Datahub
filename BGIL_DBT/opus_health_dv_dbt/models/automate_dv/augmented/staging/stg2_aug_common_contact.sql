-- automate_dv.stage() for SAT_AUG_COMMON_CONTACT, read off central view stitch_v15_party.
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
      - 'CONTACT_PERSON_DESIGNATION'
      - 'CONTACT_PERSON_NAME'
      - 'CONTACT_POINT'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_COMMON_CONTACT__CONTACT_PERSON_DESIGNATION, AUG_COMMON_CONTACT__CONTACT_PERSON_NAME, AUG_COMMON_CONTACT__CONTACT_POINT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CONTACT_PERSON_DESIGNATION: 'AUG_COMMON_CONTACT__CONTACT_PERSON_DESIGNATION'
  CONTACT_PERSON_NAME: 'AUG_COMMON_CONTACT__CONTACT_PERSON_NAME'
  CONTACT_POINT: 'AUG_COMMON_CONTACT__CONTACT_POINT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
