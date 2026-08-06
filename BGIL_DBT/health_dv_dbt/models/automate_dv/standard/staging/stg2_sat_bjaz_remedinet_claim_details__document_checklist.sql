{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_DOCUMENT_CHECKLIST, table 'BJAZ_REMEDINET_CLAIM_DETAILS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_remedinet_claim_details'
hashed_columns:
  DOCUMENT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RECEIVED_INDICATOR'
derived_columns:
  PARENT_BK: 'omni_inward_no'
  PARENT_NK: "'HUB_DOCUMENT|' || (omni_inward_no)"
  REQUIRED_DOCUMENT_TYPE_CK: '!'
  RECEIVED_INDICATOR: 'is_document_received'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_REMEDINET_CLAIM_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
