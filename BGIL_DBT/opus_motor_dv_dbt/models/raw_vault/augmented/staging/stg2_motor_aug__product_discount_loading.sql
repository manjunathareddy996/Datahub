-- automate_dv.stage() for SAT_AUG_PRODUCT_DISCOUNT_LOADING, read off central view stitch_motor__v21_product.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v21_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPLICABLE_CLAIM_PATTERN_CODE'
      - 'APPLICABLE_COVER_PACKAGE_CODE'
      - 'APPLICABLE_VEHICLE_TYPE_CODE'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  PRODUCT_NK: "case when coalesce(AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_CLAIM_PATTERN_CODE, AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_COVER_PACKAGE_CODE, AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_VEHICLE_TYPE_CODE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'AUG_PRODUCT_DISCOUNT_LOADING__ACTIVE_SEQUENCE_NUMBER_CK'
  APPLICABLE_CLAIM_PATTERN_CODE: 'AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_CLAIM_PATTERN_CODE'
  APPLICABLE_COVER_PACKAGE_CODE: 'AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_COVER_PACKAGE_CODE'
  APPLICABLE_VEHICLE_TYPE_CODE: 'AUG_PRODUCT_DISCOUNT_LOADING__APPLICABLE_VEHICLE_TYPE_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v21_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
