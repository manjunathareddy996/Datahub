{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_PRODUCT_VARIANT, 3 contributing table(s).
-- Member ends: HUB_PRODUCT (PRODUCT_FROM_HKEY), HUB_PRODUCT (PRODUCT_TO_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_product_variant.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_bandhan_medi_clam__product_variant'
  - 'stg2_link_bjaz_generic_loader_log_table__product_variant'
  - 'stg2_link_bjaz_gc_group_guard_dtls__product_variant'
src_pk: 'PRODUCT_VARIANT_HKEY'
src_fk:
  - 'PRODUCT_FROM_HKEY'
  - 'PRODUCT_TO_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
