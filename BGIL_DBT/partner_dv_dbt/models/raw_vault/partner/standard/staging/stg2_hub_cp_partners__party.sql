{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for HUB_PARTY branch 'CP_PARTNERS'.
-- Provenance: explicit. CP_PARTNERS carries every partner_id, so this single
-- branch is authoritative for the full HUB_PARTY key set.

{%- set yaml_metadata -%}
source_model: 'stg_partner__cp_partners'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!CP_PARTNERS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
