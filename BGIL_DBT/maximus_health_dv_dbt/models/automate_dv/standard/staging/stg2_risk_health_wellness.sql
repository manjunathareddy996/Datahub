-- automate_dv.stage() for SAT_RISK_HEALTH_WELLNESS, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'STEPS_AVERAGE'
      - 'WELLNESS_PROGRAMME_ENROLLED_INDICATOR'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_HEALTH_WELLNESS__STEPS_AVERAGE, RISK_HEALTH_WELLNESS__WELLNESS_PROGRAMME_ENROLLED_INDICATOR) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  STEPS_AVERAGE: 'RISK_HEALTH_WELLNESS__STEPS_AVERAGE'
  WELLNESS_PROGRAMME_ENROLLED_INDICATOR: 'RISK_HEALTH_WELLNESS__WELLNESS_PROGRAMME_ENROLLED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
