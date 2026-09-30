{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_AGENT branch 'BJAZ_INTERMEDIARY'.
-- Provenance: explicit. BJAZ_INTERMEDIARY is the intermediary/agent master table, so
-- INTERMEDIARY_ID is the authoritative business key for the full HUB_AGENT key set.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary'
hashed_columns:
  AGENT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_AGENT|' || (intermediary_id)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_INTERMEDIARY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
