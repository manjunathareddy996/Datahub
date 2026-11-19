-- automate_dv.stage() for SAT_MOTOR_AUG_PRODUCT_TERMS, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHASSIS_NUMBER_VALIDATION_PATTERN'
      - 'ENGINE_NUMBER_VALIDATION_PATTERN'
derived_columns:
  PRODUCT_NK: "case when coalesce(AUG_PRODUCT_TERMS__CHASSIS_NUMBER_VALIDATION_PATTERN, AUG_PRODUCT_TERMS__ENGINE_NUMBER_VALIDATION_PATTERN) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  CHASSIS_NUMBER_VALIDATION_PATTERN: 'AUG_PRODUCT_TERMS__CHASSIS_NUMBER_VALIDATION_PATTERN'
  ENGINE_NUMBER_VALIDATION_PATTERN: 'AUG_PRODUCT_TERMS__ENGINE_NUMBER_VALIDATION_PATTERN'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
