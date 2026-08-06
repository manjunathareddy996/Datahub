{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_RISK_OBJECT_DOCUMENT, 1 contributing table(s).
-- Member ends: HUB_DOCUMENT (DOCUMENT_HKEY), HUB_RISK_OBJECT (RISK_OBJECT_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_risk_object_document.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_ec_mem_dtls_extn__risk_object_document'
src_pk: 'RISK_OBJECT_DOCUMENT_HKEY'
src_fk:
  - 'DOCUMENT_HKEY'
  - 'RISK_OBJECT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
