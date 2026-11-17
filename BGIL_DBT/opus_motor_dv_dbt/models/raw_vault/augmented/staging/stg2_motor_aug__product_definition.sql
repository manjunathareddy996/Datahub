-- automate_dv.stage() for SAT_AUG_PRODUCT_DEFINITION, read off central view stitch_motor__v21_product.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v21_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPLICABLE_VEHICLE_TYPE_CODE'
      - 'PRODUCT_PACKAGE_NAME'
      - 'PRODUCT_TENURE_YEARS'
derived_columns:
  PRODUCT_NK: "case when coalesce(AUG_PRODUCT_DEFINITION__APPLICABLE_VEHICLE_TYPE_CODE, AUG_PRODUCT_DEFINITION__PRODUCT_PACKAGE_NAME, AUG_PRODUCT_DEFINITION__PRODUCT_TENURE_YEARS) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  APPLICABLE_VEHICLE_TYPE_CODE: 'AUG_PRODUCT_DEFINITION__APPLICABLE_VEHICLE_TYPE_CODE'
  PRODUCT_PACKAGE_NAME: 'AUG_PRODUCT_DEFINITION__PRODUCT_PACKAGE_NAME'
  PRODUCT_TENURE_YEARS: 'AUG_PRODUCT_DEFINITION__PRODUCT_TENURE_YEARS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v21_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
