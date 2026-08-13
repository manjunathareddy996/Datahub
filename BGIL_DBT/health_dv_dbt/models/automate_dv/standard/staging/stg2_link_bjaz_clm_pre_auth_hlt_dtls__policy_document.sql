{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_POLICY_DOCUMENT member-end 'bjaz_clm_pre_auth_hlt_dtls'.
-- DOCUMENT_HKEY is hashed with the EXACT SAME formula ('HUB_DOCUMENT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for POLICY_HKEY.
-- POLICY_DOCUMENT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_clm_pre_auth_hlt_dtls'
hashed_columns:
  DOCUMENT_HKEY: 'DOCUMENT_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  POLICY_DOCUMENT_HKEY: 'POLICY_DOCUMENT_HKEY_NK'
derived_columns:
  DOCUMENT_HKEY_NK: "'HUB_DOCUMENT|' || card_no"
  POLICY_HKEY_NK: "'HUB_POLICY|' || contract_id"
  POLICY_DOCUMENT_HKEY_NK: "'LNK_POLICY_DOCUMENT|' || card_no || '|' || contract_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CLM_PRE_AUTH_HLT_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
