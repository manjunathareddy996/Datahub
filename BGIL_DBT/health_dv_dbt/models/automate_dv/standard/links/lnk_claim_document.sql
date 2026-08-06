{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_CLAIM_DOCUMENT, 8 contributing table(s).
-- Member ends: HUB_CLAIM (CLAIM_HKEY), HUB_DOCUMENT (DOCUMENT_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_claim_document.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_hm_clm_register__claim_document'
  - 'stg2_link_bjaz_hm_inward_autoallocation__claim_document'
  - 'stg2_link_bjaz_hm_inward_dtls__claim_document'
  - 'stg2_link_bjaz_hm_outward_dtls__claim_document'
  - 'stg2_link_bjaz_hm_preauth_enhance__claim_document'
  - 'stg2_link_bjaz_hm_preauth_query__claim_document'
  - 'stg2_link_bjaz_remedinet_claim_details__claim_document'
  - 'stg2_link_bjaz_clm_pre_auth_hlt_dtls__claim_document'
src_pk: 'CLAIM_DOCUMENT_HKEY'
src_fk:
  - 'CLAIM_HKEY'
  - 'DOCUMENT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
