{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_CASE_DOCUMENT, 3 contributing table(s).
-- Member ends: HUB_CASE (CASE_HKEY), HUB_DOCUMENT (DOCUMENT_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_case_document.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_hm_inward_autoallocation__case_document'
  - 'stg2_link_bjaz_hm_preauth_enhance__case_document'
  - 'stg2_link_bjaz_hm_preauth_query__case_document'
src_pk: 'CASE_DOCUMENT_HKEY'
src_fk:
  - 'CASE_HKEY'
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
