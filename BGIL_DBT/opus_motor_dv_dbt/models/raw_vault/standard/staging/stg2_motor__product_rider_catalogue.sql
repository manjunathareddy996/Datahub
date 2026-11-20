-- automate_dv.stage() for SAT_PRODUCT_RIDER_CATALOGUE, read off central view stitch_motor__v20_product.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v20_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EFFECTIVE_DATE'
      - 'RIDER_CODE'
      - 'RIDER_NAME'
      - 'RIDER_TYPE'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  PRODUCT_NK: "case when coalesce(PRODUCT_RIDER_CATALOGUE__EFFECTIVE_DATE, PRODUCT_RIDER_CATALOGUE__RIDER_CODE, PRODUCT_RIDER_CATALOGUE__RIDER_NAME, PRODUCT_RIDER_CATALOGUE__RIDER_TYPE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'PRODUCT_RIDER_CATALOGUE__ACTIVE_SEQUENCE_NUMBER_CK'
  EFFECTIVE_DATE: 'PRODUCT_RIDER_CATALOGUE__EFFECTIVE_DATE'
  RIDER_CODE: 'PRODUCT_RIDER_CATALOGUE__RIDER_CODE'
  RIDER_NAME: 'PRODUCT_RIDER_CATALOGUE__RIDER_NAME'
  RIDER_TYPE: 'PRODUCT_RIDER_CATALOGUE__RIDER_TYPE'
  LOAD_DATETIME: 'PRODUCT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v20_product'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
