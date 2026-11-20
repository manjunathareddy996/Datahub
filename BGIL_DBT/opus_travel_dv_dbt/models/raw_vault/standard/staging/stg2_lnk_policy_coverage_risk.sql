{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stage() for LNK_POLICY_COVERAGE_RISK: hub keys and the link key, hashed off stitch_travel__lnk_policy_coverage_risk.
-- Link NK = 'LNK_x|' || leg business keys in alphabetical hub order (same convention as Motor/Health).
{%- set yaml_metadata -%}
source_model: 'stitch_travel__lnk_policy_coverage_risk'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  POLICY_HKEY: 'POLICY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  POLICY_COVERAGE_RISK_HKEY: 'POLICY_COVERAGE_RISK_NK'
derived_columns:
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  POLICY_COVERAGE_RISK_NK: "'LNK_POLICY_COVERAGE_RISK|' || COVERAGE_BK || '|' || POLICY_BK || '|' || RISK_OBJECT_BK"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: 'RECORD_SRC'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
