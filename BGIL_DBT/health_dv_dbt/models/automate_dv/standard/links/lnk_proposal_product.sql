{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_PROPOSAL_PRODUCT, 10 contributing table(s).
-- Member ends: HUB_PRODUCT (PRODUCT_HKEY), HUB_PROPOSAL (PROPOSAL_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_proposal_product.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_gp_hospital_cash__proposal_product'
  - 'stg2_link_bjaz_grp_hlt_dtls__proposal_product'
  - 'stg2_link_bjaz_hdfc_sec_fhpp__proposal_product'
  - 'stg2_link_bjaz_hg_pol_dtls__proposal_product'
  - 'stg2_link_bjaz_adld_prem_dtls__proposal_product'
  - 'stg2_link_bjaz_flexi_cyber_data__proposal_product'
  - 'stg2_link_bjaz_gg_prem_dtls__proposal_product'
  - 'stg2_link_bjaz_hdfc_flexipa__proposal_product'
  - 'stg2_link_bjaz_pnb_gpa_data__proposal_product'
  - 'stg2_link_bjaz_rr_prem_dtls__proposal_product'
src_pk: 'PROPOSAL_PRODUCT_HKEY'
src_fk:
  - 'PRODUCT_HKEY'
  - 'PROPOSAL_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
