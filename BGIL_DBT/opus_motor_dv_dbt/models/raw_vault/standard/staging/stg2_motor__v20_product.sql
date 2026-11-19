-- automate_dv.stage() over central view stitch_motor__v20_product: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v20_product'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  QUOTE_PRODUCT_HKEY: 'QUOTE_PRODUCT_NK'
derived_columns:
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  QUOTE_BK: 'QUOTE_BK'
  QUOTE_NK: "'HUB_QUOTE|' || QUOTE_BK"
  QUOTE_PRODUCT_NK: "case when __LNK_QUOTE_PRODUCT = 1 then 'LNK_QUOTE_PRODUCT|' || PRODUCT_BK || '|' || QUOTE_BK end"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v20_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
