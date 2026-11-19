-- automate_dv.stage() for SAT_MOTOR_AUG_COMMON_ADDRESS, read off central view stitch_motor__v08_org_unit.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v08_org_unit'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE4'
      - 'ADDRESS_LINE_5'
      - 'CITY_OTHER_TEXT'
      - 'FULL_ADDRESS_TEXT'
      - 'LOCALITY_OTHER_TEXT'
      - 'SAME_AS_RISK_ADDRESS_INDICATOR'
derived_columns:
  LOCATION_NK: "case when coalesce(AUG_COMMON_ADDRESS__ADDRESS_LINE4, AUG_COMMON_ADDRESS__ADDRESS_LINE_5, AUG_COMMON_ADDRESS__CITY_OTHER_TEXT, AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT, AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT, AUG_COMMON_ADDRESS__SAME_AS_RISK_ADDRESS_INDICATOR) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  ADDRESS_LINE4: 'AUG_COMMON_ADDRESS__ADDRESS_LINE4'
  ADDRESS_LINE_5: 'AUG_COMMON_ADDRESS__ADDRESS_LINE_5'
  CITY_OTHER_TEXT: 'AUG_COMMON_ADDRESS__CITY_OTHER_TEXT'
  FULL_ADDRESS_TEXT: 'AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT'
  LOCALITY_OTHER_TEXT: 'AUG_COMMON_ADDRESS__LOCALITY_OTHER_TEXT'
  SAME_AS_RISK_ADDRESS_INDICATOR: 'AUG_COMMON_ADDRESS__SAME_AS_RISK_ADDRESS_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v08_org_unit'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
