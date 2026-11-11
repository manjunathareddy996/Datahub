-- automate_dv.stage() for SAT_AUG_RISK_HEALTH_WELLNESS, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISTANCE_RUN_KILOMETRES'
      - 'WELLNESS_DEVICE_RETURNED_INDICATOR'
      - 'WELLNESS_EVENT_NAME'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_HEALTH_WELLNESS__DISTANCE_RUN_KILOMETRES, AUG_RISK_HEALTH_WELLNESS__WELLNESS_DEVICE_RETURNED_INDICATOR, AUG_RISK_HEALTH_WELLNESS__WELLNESS_EVENT_NAME) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  DISTANCE_RUN_KILOMETRES: 'AUG_RISK_HEALTH_WELLNESS__DISTANCE_RUN_KILOMETRES'
  WELLNESS_DEVICE_RETURNED_INDICATOR: 'AUG_RISK_HEALTH_WELLNESS__WELLNESS_DEVICE_RETURNED_INDICATOR'
  WELLNESS_EVENT_NAME: 'AUG_RISK_HEALTH_WELLNESS__WELLNESS_EVENT_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
