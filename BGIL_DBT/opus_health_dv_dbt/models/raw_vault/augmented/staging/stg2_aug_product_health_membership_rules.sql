-- automate_dv.stage() for SAT_AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES, read off central view stitch_v32_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v32_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FAMILY_FLOATER_DETAILS_ONLY_INDICATOR'
      - 'MEMBER_PIN_CODE_VALIDATION_REQUIRED_INDICATOR'
      - 'SELF_MEMBER_EXCLUSION_ALLOWED_INDICATOR'
derived_columns:
  PRODUCT_NK: "case when coalesce(AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES__FAMILY_FLOATER_DETAILS_ONLY_INDICATOR, AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES__MEMBER_PIN_CODE_VALIDATION_REQUIRED_INDICATOR, AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES__SELF_MEMBER_EXCLUSION_ALLOWED_INDICATOR) is not null then 'HUB_PRODUCT|' || PRODUCT_BK end"
  FAMILY_FLOATER_DETAILS_ONLY_INDICATOR: 'AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES__FAMILY_FLOATER_DETAILS_ONLY_INDICATOR'
  MEMBER_PIN_CODE_VALIDATION_REQUIRED_INDICATOR: 'AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES__MEMBER_PIN_CODE_VALIDATION_REQUIRED_INDICATOR'
  SELF_MEMBER_EXCLUSION_ALLOWED_INDICATOR: 'AUG_PRODUCT_HEALTH_MEMBERSHIP_RULES__SELF_MEMBER_EXCLUSION_ALLOWED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v32_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
