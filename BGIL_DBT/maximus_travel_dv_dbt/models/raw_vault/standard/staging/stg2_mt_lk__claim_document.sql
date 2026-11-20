{{ config(materialized='view') }}
-- stage() for LNK_CLAIM_DOCUMENT: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_claim_document.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_claim_document'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  CLAIM_DOCUMENT_HKEY: 'CLAIM_DOCUMENT_NK'
derived_columns:
  CLAIM_DOCUMENT_NK: "'LNK_CLAIM_DOCUMENT|' || CLAIM_BK || '|' || DOCUMENT_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
