-- automate_dv.stage() for SAT_PRODUCT_RATING_FACTOR, read off central view stitch_motor__v20_product.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v20_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BASE_TARIFF_RATE'
      - 'EFFECTIVE_DATE'
      - 'RATING_FACTOR_CODE'
      - 'VALUE_RANGE_FROM'
      - 'VALUE_RANGE_TO'
      - 'ACTIVE_SEQUENCE_NUMBER'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_RATING_FACTOR__BASE_TARIFF_RATE, PRODUCT_RATING_FACTOR__EFFECTIVE_DATE, PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE, PRODUCT_RATING_FACTOR__VALUE_RANGE_FROM, PRODUCT_RATING_FACTOR__VALUE_RANGE_TO) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  ACTIVE_SEQUENCE_NUMBER: 'PRODUCT_RATING_FACTOR__ACTIVE_SEQUENCE_NUMBER_CK'
  BASE_TARIFF_RATE: 'PRODUCT_RATING_FACTOR__BASE_TARIFF_RATE'
  EFFECTIVE_DATE: 'PRODUCT_RATING_FACTOR__EFFECTIVE_DATE'
  RATING_FACTOR_CODE: 'PRODUCT_RATING_FACTOR__RATING_FACTOR_CODE'
  VALUE_RANGE_FROM: 'PRODUCT_RATING_FACTOR__VALUE_RANGE_FROM'
  VALUE_RANGE_TO: 'PRODUCT_RATING_FACTOR__VALUE_RANGE_TO'
  LOAD_DATETIME: 'PRODUCT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_MOTOR_V20_PRODUCT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
