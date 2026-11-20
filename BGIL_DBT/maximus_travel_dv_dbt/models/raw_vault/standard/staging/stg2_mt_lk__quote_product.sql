{{ config(materialized='view') }}
-- stage() for LNK_QUOTE_PRODUCT: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_quote_product.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_quote_product'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_PRODUCT_HKEY: 'QUOTE_PRODUCT_NK'
derived_columns:
  QUOTE_PRODUCT_NK: "'LNK_QUOTE_PRODUCT|' || QUOTE_BK || '|' || PRODUCT_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
