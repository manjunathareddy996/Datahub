{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_PRODUCT_COVERAGE: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_product_coverage.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_product_coverage'
hashed_columns:
  PRODUCT_HKEY: 'PRODUCT_NK'
  COVERAGE_HKEY: 'COVERAGE_NK'
  PRODUCT_COVERAGE_HKEY: 'PRODUCT_COVERAGE_NK'
derived_columns:
  PRODUCT_COVERAGE_NK: "'LNK_PRODUCT_COVERAGE|' || PRODUCT_BK || '|' || COVERAGE_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
