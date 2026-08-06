{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_QUOTE_PRODUCT, 7 contributing table(s).
-- Member ends: HUB_PRODUCT (PRODUCT_HKEY), HUB_QUOTE (QUOTE_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_quote_product.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_grp_hlt_cust_dtls__quote_product'
  - 'stg2_link_bjaz_grp_hlt_dtls__quote_product'
  - 'stg2_link_bjaz_grp_hlt_imd_dtls__quote_product'
  - 'stg2_link_bjaz_grp_hlt_maternity_dtls__quote_product'
  - 'stg2_link_bjaz_hg_pol_dtls__quote_product'
  - 'stg2_link_bjaz_ewr_pol_dtls__quote_product'
  - 'stg2_link_bjaz_hdfc_surk_shop__quote_product'
src_pk: 'QUOTE_PRODUCT_HKEY'
src_fk:
  - 'PRODUCT_HKEY'
  - 'QUOTE_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
