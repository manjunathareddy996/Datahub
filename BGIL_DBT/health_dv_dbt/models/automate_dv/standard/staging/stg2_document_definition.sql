{{ config(materialized='view') }}

-- STANDARD-MODEL stage() pass for stitch_document_definition -- serves SAT_DOCUMENT_DEFINITION.
-- The ONE place DOCUMENT_HK gets hashed for this cluster (namespaced: 'HUB_DOCUMENT|' || raw key,
-- same collision-prevention convention as the rest of this build -- see gen_common.namespaced_hash).

{%- set yaml_metadata -%}
source_model: 'stitch_document_definition'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_CATEGORY'
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_REFERENCE_NUMBER'
      - 'DOCUMENT_STATUS'
      - 'DOCUMENT_TYPE'
      - 'EXPIRY_DATE'
      - 'RECEIVED_DATE'
      - 'STORAGE_REFERENCE'
derived_columns:
  DOCUMENT_NK: "'HUB_DOCUMENT|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
