{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() -- table 'AZBJ_PARTNER_EXTN'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__azbj_partner_extn'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_HKEY_NK'
derived_columns:
  PARTY_HKEY_NK: "'HUB_PARTY|' || part_id"
  POLICY_HKEY_NK: "'HUB_POLICY|' || existing_policy_pid"
  POLICY_PARTY_HKEY_NK: "'LNK_POLICY_PARTY|' || part_id || '|' || existing_policy_pid"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!AZBJ_PARTNER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
