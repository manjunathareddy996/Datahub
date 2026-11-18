-- automate_dv.stage() for SAT_ASSESSMENT_HEADER, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSESSMENT_STATUS'
derived_columns:
  ASSESSMENT_NK: "case when ASSESSMENT_HEADER__ASSESSMENT_STATUS is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  ASSESSMENT_STATUS: 'ASSESSMENT_HEADER__ASSESSMENT_STATUS'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
