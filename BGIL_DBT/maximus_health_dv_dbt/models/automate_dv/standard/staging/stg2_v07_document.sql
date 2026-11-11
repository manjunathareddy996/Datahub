-- automate_dv.stage() over central view stitch_v07_document: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_document'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
derived_columns:
  DOCUMENT_BK: 'DOCUMENT_BK'
  DOCUMENT_NK: "'HUB_DOCUMENT|' || DOCUMENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_document'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
