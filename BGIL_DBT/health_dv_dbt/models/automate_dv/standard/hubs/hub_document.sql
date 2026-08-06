{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_DOCUMENT, 14 contributing table(s)
-- across 11 source_model entries (1 via stitch-stage,
-- 10 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_document_definition'
  - 'stg2_hub_bjaz_ec_mem_dtls_extn__document'
  - 'stg2_hub_bjaz_hm_clm_register__document'
  - 'stg2_hub_bjaz_hm_inward_autoallocation__document'
  - 'stg2_hub_bjaz_hm_outward_dtls__document'
  - 'stg2_hub_bjaz_hm_preauth_enhance__document'
  - 'stg2_hub_bjaz_hm_preauth_query__document'
  - 'stg2_hub_bjaz_ihg_mem_dtls_extn__document'
  - 'stg2_hub_bjaz_sh_mem_dtls_extn__document'
  - 'stg2_hub_bjaz_clm_pre_auth_hlt_dtls__document'
  - 'stg2_hub_ng_hcm_inward_details__document'
src_pk: 'DOCUMENT_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
