-- automate_dv.stage() for SAT_COMMON_ADMIN_GEOGRAPHY, read off central view stitch_motor__v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v15_policy'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISTRICT_NAME'
      - 'PIN_CODE'
      - 'RTO_REGION_CODE'
      - 'STATE_NAME'
derived_columns:
  LOCATION_NK: "case when coalesce(COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME, COMMON_ADMIN_GEOGRAPHY__PIN_CODE, COMMON_ADMIN_GEOGRAPHY__RTO_REGION_CODE, COMMON_ADMIN_GEOGRAPHY__STATE_NAME) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  DISTRICT_NAME: 'COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME'
  PIN_CODE: 'COMMON_ADMIN_GEOGRAPHY__PIN_CODE'
  RTO_REGION_CODE: 'COMMON_ADMIN_GEOGRAPHY__RTO_REGION_CODE'
  STATE_NAME: 'COMMON_ADMIN_GEOGRAPHY__STATE_NAME'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V15_POLICY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
