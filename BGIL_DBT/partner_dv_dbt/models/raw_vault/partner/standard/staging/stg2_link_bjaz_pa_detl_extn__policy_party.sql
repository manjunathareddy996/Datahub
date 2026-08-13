{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() -- table 'BJAZ_PA_DETL_EXTN'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_pa_detl_extn'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || partner_id"
  POLICY_HKEY_NK: "'HUB_POLICY|' || contract_id"
  POLICY_PARTY_HKEY_NK: "'LNK_POLICY_PARTY|' || partner_id || '|' || contract_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_PA_DETL_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
