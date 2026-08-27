{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_LNK_CLAIM_PARTY_ROLE, table
-- 'CLM_INTERESTED_PARTIES'. New in data_5b (docs/PARTNER_BUILD_STATE.md section 1).
-- Reuses the exact CLAIM_PARTY_HKEY formula from stg2_link_clm_interested_parties__claim_party.sql
-- so this row always matches a real LNK_CLAIM_PARTY row.

{%- set yaml_metadata -%}
source_model: 'stg_partner__clm_interested_parties'
hashed_columns:
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_HKEY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_SEQUENCE'
derived_columns:
  CLAIM_PARTY_HKEY_NK: "'LNK_CLAIM_PARTY|' || part_id || '|' || claim_id"
  PARTY_ROLE_TYPE: 'ip_type'
  ROLE_SEQUENCE: 'ip_no'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!CLM_INTERESTED_PARTIES'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
