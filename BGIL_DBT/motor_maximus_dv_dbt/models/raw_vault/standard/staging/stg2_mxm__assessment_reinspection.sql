-- automate_dv.stage() for SAT_ASSESSMENT_REINSPECTION, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RE_INSPECTION_DATE'
      - 'RE_INSPECTION_TIME'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_REINSPECTION__RE_INSPECTION_DATE, ASSESSMENT_REINSPECTION__RE_INSPECTION_TIME) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  RE_INSPECTION_DATE: 'ASSESSMENT_REINSPECTION__RE_INSPECTION_DATE'
  RE_INSPECTION_TIME: 'ASSESSMENT_REINSPECTION__RE_INSPECTION_TIME'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
