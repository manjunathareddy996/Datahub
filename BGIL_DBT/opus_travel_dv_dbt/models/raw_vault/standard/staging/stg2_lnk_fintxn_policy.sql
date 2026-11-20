{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_FINTXN_POLICY: hub keys and the link key, hashed off stitch_travel__lnk_fintxn_policy.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_fintxn_policy'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  POLICY_HKEY: 'POLICY_NK'
  FINTXN_POLICY_HKEY: 'FINTXN_POLICY_NK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  FINTXN_POLICY_NK: "'LNK_FINTXN_POLICY|' || FINANCIAL_TRANSACTION_BK || '|' || POLICY_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
