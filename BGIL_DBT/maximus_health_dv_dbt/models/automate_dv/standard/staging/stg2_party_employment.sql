-- automate_dv.stage() for SAT_PARTY_EMPLOYMENT, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DESIGNATION'
      - 'EMPLOYER_NAME'
      - 'EMPLOYMENT_STATUS'
      - 'OCCUPATION_CODE'
      - 'OCCUPATION_DESCRIPTION'
      - 'PROFESSIONAL_REGISTRATION_NUMBER'
      - 'WORK_NATURE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_EMPLOYMENT__DESIGNATION, PARTY_EMPLOYMENT__EMPLOYER_NAME, PARTY_EMPLOYMENT__EMPLOYMENT_STATUS, PARTY_EMPLOYMENT__OCCUPATION_CODE, PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION, PARTY_EMPLOYMENT__PROFESSIONAL_REGISTRATION_NUMBER, PARTY_EMPLOYMENT__WORK_NATURE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  DESIGNATION: 'PARTY_EMPLOYMENT__DESIGNATION'
  EMPLOYER_NAME: 'PARTY_EMPLOYMENT__EMPLOYER_NAME'
  EMPLOYMENT_STATUS: 'PARTY_EMPLOYMENT__EMPLOYMENT_STATUS'
  OCCUPATION_CODE: 'PARTY_EMPLOYMENT__OCCUPATION_CODE'
  OCCUPATION_DESCRIPTION: 'PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION'
  PROFESSIONAL_REGISTRATION_NUMBER: 'PARTY_EMPLOYMENT__PROFESSIONAL_REGISTRATION_NUMBER'
  WORK_NATURE: 'PARTY_EMPLOYMENT__WORK_NATURE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
