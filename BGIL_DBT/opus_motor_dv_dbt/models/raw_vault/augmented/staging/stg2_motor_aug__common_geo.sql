-- automate_dv.stage() for SAT_MOTOR_AUG_COMMON_GEO, read off central view stitch_motor__v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v15_policy'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TEMPERATURE_ZONE_CODE'
derived_columns:
  LOCATION_NK: "case when AUG_COMMON_GEO__TEMPERATURE_ZONE_CODE is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  TEMPERATURE_ZONE_CODE: 'AUG_COMMON_GEO__TEMPERATURE_ZONE_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
