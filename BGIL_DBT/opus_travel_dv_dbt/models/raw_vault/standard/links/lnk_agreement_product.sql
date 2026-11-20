{{ config(materialized='incremental') }}
-- TRAVEL STANDARD-MODEL link() for LNK_AGREEMENT_PRODUCT (Agreement Product Scope). Writes the shared LNK_AGREEMENT_PRODUCT table.
{%- set yaml_metadata -%}
source_model: 'stg2_lnk_agreement_product'
src_pk: 'AGREEMENT_PRODUCT_HKEY'
src_fk:
  - 'AGREEMENT_HKEY'
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
