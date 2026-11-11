-- automate_dv.stage() over central view stitch_v09_financial_transaction: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_financial_transaction'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  POLICY_HKEY: 'POLICY_NK'
derived_columns:
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  FINANCIAL_TRANSACTION_BK: 'FINANCIAL_TRANSACTION_BK'
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
