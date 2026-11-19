-- automate_dv.stage() for SAT_ASSESSMENT_PRE_INSPECTION, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INSPECTION_AGENCY_CODE'
      - 'INSPECTION_DATE'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_PRE_INSPECTION__INSPECTION_AGENCY_CODE, ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  INSPECTION_AGENCY_CODE: 'ASSESSMENT_PRE_INSPECTION__INSPECTION_AGENCY_CODE'
  INSPECTION_DATE: 'ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V10_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
