-- automate_dv.stage() for SAT_PARTY_GROUP_CENSUS, read off central view stitch_v12_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v12_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DESIGNATION_BAND'
      - 'EMPLOYEE_ID'
      - 'EXIT_DATE'
      - 'MEMBER_REFERENCE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_GROUP_CENSUS__DESIGNATION_BAND, PARTY_GROUP_CENSUS__EMPLOYEE_ID, PARTY_GROUP_CENSUS__EXIT_DATE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  MEMBER_REFERENCE_CK: 'PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK'
  DESIGNATION_BAND: 'PARTY_GROUP_CENSUS__DESIGNATION_BAND'
  EMPLOYEE_ID: 'PARTY_GROUP_CENSUS__EMPLOYEE_ID'
  EXIT_DATE: 'PARTY_GROUP_CENSUS__EXIT_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v12_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
