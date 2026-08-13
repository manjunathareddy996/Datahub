{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_FINTXN_POLICY member-end 'bjaz_health_webservice_info'.
-- FINANCIAL_TRANSACTION_HKEY is hashed with the EXACT SAME formula ('HUB_FINANCIAL_TRANSACTION|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for POLICY_HKEY.
-- FINTXN_POLICY_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_HKEY_NK'
  POLICY_HKEY: 'POLICY_HKEY_NK'
  FINTXN_POLICY_HKEY: 'FINTXN_POLICY_HKEY_NK'
derived_columns:
  FINANCIAL_TRANSACTION_HKEY_NK: "'HUB_FINANCIAL_TRANSACTION|' || ptransaction_id"
  POLICY_HKEY_NK: "'HUB_POLICY|' || policy_ref"
  FINTXN_POLICY_HKEY_NK: "'LNK_FINTXN_POLICY|' || ptransaction_id || '|' || policy_ref"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
