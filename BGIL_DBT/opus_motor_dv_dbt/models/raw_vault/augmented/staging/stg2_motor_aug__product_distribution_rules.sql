-- automate_dv.stage() for SAT_MOTOR_AUG_PRODUCT_DISTRIBUTION_RULES, read off central view stitch_motor__v06_distribution_channel.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v06_distribution_channel'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RTA_CONFIGURATION_RULE_TYPE'
      - 'RTA_CONFIGURATION_VEHICLE_TYPE_CODE'
derived_columns:
  PRODUCT_NK: "case when coalesce(AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_RULE_TYPE, AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_VEHICLE_TYPE_CODE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  RTA_CONFIGURATION_RULE_TYPE: 'AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_RULE_TYPE'
  RTA_CONFIGURATION_VEHICLE_TYPE_CODE: 'AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_VEHICLE_TYPE_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v06_distribution_channel'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
