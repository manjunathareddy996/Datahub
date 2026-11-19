-- automate_dv.stage() for SAT_MOTOR_AUG_PRODUCT_TAX_APPLICABILITY, read off central view stitch_motor__v20_product.
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
      - 'THIRD_PARTY_GST_APPLICABLE_INDICATOR'
      - 'VEHICLE_CATEGORY_CODE'
      - 'VEHICLE_CATEGORY_CODE_CK'
      - 'EFFECTIVE_DATE_CK'
derived_columns:
  PRODUCT_NK: "case when coalesce(AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE, AUG_PRODUCT_TAX_APPLICABILITY__THIRD_PARTY_GST_APPLICABLE_INDICATOR, AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  VEHICLE_CATEGORY_CODE_CK: 'AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE_CK'
  EFFECTIVE_DATE_CK: 'AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE_CK'
  EFFECTIVE_DATE: 'AUG_PRODUCT_TAX_APPLICABILITY__EFFECTIVE_DATE'
  THIRD_PARTY_GST_APPLICABLE_INDICATOR: 'AUG_PRODUCT_TAX_APPLICABILITY__THIRD_PARTY_GST_APPLICABLE_INDICATOR'
  VEHICLE_CATEGORY_CODE: 'AUG_PRODUCT_TAX_APPLICABILITY__VEHICLE_CATEGORY_CODE'
  LOAD_DATETIME: 'PRODUCT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v20_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
