{{ config(materialized='incremental') }}
-- PARTNER STANDARD-MODEL link() for LNK_PARTY_DOCUMENT (Party Document), 3 contributing table(s). BUILD-SIDE: not in the mapper's map.
-- Writes the SAME physical table as the other builds' model of the same name.
{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_bjaz_t_kyc_ocr__party_document'
  - 'stg2_link_bjaz_t_kyc_poa_document__party_document'
  - 'stg2_link_bjaz_t_kyc_poi_document__party_document'
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
