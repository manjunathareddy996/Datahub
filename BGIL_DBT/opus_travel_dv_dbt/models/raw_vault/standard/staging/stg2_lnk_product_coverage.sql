{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_PRODUCT_COVERAGE: hub keys and the link key, hashed off stitch_travel__lnk_product_coverage.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_product_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  PRODUCT_COVERAGE_HKEY: 'PRODUCT_COVERAGE_NK'
derived_columns:
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  PRODUCT_COVERAGE_NK: "'LNK_PRODUCT_COVERAGE|' || COVERAGE_BK || '|' || PRODUCT_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
