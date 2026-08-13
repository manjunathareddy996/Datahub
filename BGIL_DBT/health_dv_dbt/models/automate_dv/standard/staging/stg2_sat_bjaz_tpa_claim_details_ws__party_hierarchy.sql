{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_HIERARCHY, table 'BJAZ_TPA_CLAIM_DETAILS_WS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DEVELOPMENT_OFFICER_REFERENCE'
derived_columns:
  PARENT_BK: 'customer_id'
  PARENT_NK: "'HUB_PARTY|' || (customer_id)"
  DEVELOPMENT_OFFICER_REFERENCE: 'development_code'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
