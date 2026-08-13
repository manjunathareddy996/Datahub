{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for LNK_FINTXN_ACCOUNT member-end 'bjaz_health_webservice_info'.
-- FINANCIAL_ACCOUNT_HKEY is hashed with the EXACT SAME formula ('HUB_FINANCIAL_ACCOUNT|' || raw key) as
-- that hub's own stage() models -- guaranteed identical hkey for the same raw value,
-- a genuine foreign key, not independently re-derived. Same for FINANCIAL_TRANSACTION_HKEY.
-- FINTXN_ACCOUNT_HKEY is this link's own PK -- doesn't need to match anything external.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'FINANCIAL_ACCOUNT_HKEY_NK'
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_HKEY_NK'
  FINTXN_ACCOUNT_HKEY: 'FINTXN_ACCOUNT_HKEY_NK'
derived_columns:
  FINANCIAL_ACCOUNT_HKEY_NK: "'HUB_FINANCIAL_ACCOUNT|' || loan_accno"
  FINANCIAL_TRANSACTION_HKEY_NK: "'HUB_FINANCIAL_TRANSACTION|' || ptransaction_id"
  FINTXN_ACCOUNT_HKEY_NK: "'LNK_FINTXN_ACCOUNT|' || loan_accno || '|' || ptransaction_id"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
