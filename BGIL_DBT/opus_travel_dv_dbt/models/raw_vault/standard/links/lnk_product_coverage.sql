{{ config(materialized='incremental') }}
-- TRAVEL STANDARD-MODEL link() for LNK_PRODUCT_COVERAGE (Product Coverage). Writes the shared LNK_PRODUCT_COVERAGE table.
{%- set yaml_metadata -%}
source_model: 'stg2_lnk_product_coverage'
src_pk: 'PRODUCT_COVERAGE_HKEY'
src_fk:
  - 'COVERAGE_HKEY'
  - 'PRODUCT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                    src_fk=metadata_dict['src_fk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
