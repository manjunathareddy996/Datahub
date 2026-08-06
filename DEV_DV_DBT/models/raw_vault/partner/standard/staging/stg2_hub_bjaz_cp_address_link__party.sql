{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_PARTY branch 'BJAZ_CP_ADDRESS_LINK'.
-- Provenance: explicit.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_cp_address_link'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CP_ADDRESS_LINK'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
