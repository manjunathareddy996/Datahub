{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_PARTY_DOCUMENT, 9 contributing table(s).
-- Member ends: HUB_DOCUMENT (DOCUMENT_HKEY), HUB_PARTY (PARTY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_party_document.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_ec_mem_dtls_extn__party_document'
  - 'stg2_link_bjaz_hm_clm_register__party_document'
  - 'stg2_link_bjaz_hm_inward_dtls__party_document'
  - 'stg2_link_bjaz_hm_preauth_enhance__party_document'
  - 'stg2_link_bjaz_hm_preauth_query__party_document'
  - 'stg2_link_bjaz_ihg_mem_dtls_extn__party_document'
  - 'stg2_link_bjaz_remedinet_claim_details__party_document'
  - 'stg2_link_bjaz_sh_mem_dtls_extn__party_document'
  - 'stg2_link_bjaz_clm_pre_auth_hlt_dtls__party_document'
src_pk: 'PARTY_DOCUMENT_HKEY'
src_fk:
  - 'DOCUMENT_HKEY'
  - 'PARTY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
