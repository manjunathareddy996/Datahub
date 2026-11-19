-- automate_dv.stage() for SAT_PRODUCT_DEFINITION, read off central view stitch_motor__v05_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v05_coverage'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCT_DESCRIPTION'
      - 'PRODUCT_NAME'
      - 'PRODUCT_STATUS'
      - 'UIN'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_DEFINITION__PRODUCT_DESCRIPTION, PRODUCT_DEFINITION__PRODUCT_NAME, PRODUCT_DEFINITION__PRODUCT_STATUS, PRODUCT_DEFINITION__UIN) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  PRODUCT_DESCRIPTION: 'PRODUCT_DEFINITION__PRODUCT_DESCRIPTION'
  PRODUCT_NAME: 'PRODUCT_DEFINITION__PRODUCT_NAME'
  PRODUCT_STATUS: 'PRODUCT_DEFINITION__PRODUCT_STATUS'
  UIN: 'PRODUCT_DEFINITION__UIN'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V05_COVERAGE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
