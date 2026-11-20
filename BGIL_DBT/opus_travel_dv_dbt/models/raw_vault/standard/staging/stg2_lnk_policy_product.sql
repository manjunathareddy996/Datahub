{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_POLICY_PRODUCT: hub keys and the link key, hashed off stitch_travel__lnk_policy_product.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_policy_product'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
derived_columns:
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  POLICY_PRODUCT_NK: "'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
