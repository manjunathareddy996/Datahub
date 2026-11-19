-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_EMPLOYMENT, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMPLOYER_COMPANY_CODE'
      - 'EMPLOYER_RELATIONSHIP_TYPE'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_EMPLOYMENT__EMPLOYER_COMPANY_CODE, AUG_PARTY_EMPLOYMENT__EMPLOYER_RELATIONSHIP_TYPE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  EMPLOYER_COMPANY_CODE: 'AUG_PARTY_EMPLOYMENT__EMPLOYER_COMPANY_CODE'
  EMPLOYER_RELATIONSHIP_TYPE: 'AUG_PARTY_EMPLOYMENT__EMPLOYER_RELATIONSHIP_TYPE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V10_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
