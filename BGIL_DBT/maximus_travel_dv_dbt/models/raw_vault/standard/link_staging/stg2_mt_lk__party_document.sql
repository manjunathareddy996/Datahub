{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_PARTY_DOCUMENT: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_party_document.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_party_document'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  PARTY_DOCUMENT_HKEY: 'PARTY_DOCUMENT_NK'
derived_columns:
  PARTY_DOCUMENT_NK: "'LNK_PARTY_DOCUMENT|' || PARTY_BK || '|' || DOCUMENT_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
