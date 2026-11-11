-- automate_dv.stage() over central view stitch_v17_policy: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v17_policy'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  COVERAGE_HKEY: 'COVERAGE_NK'
  POLICY_HKEY: 'POLICY_NK'
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  POLICY_COVERAGE_HKEY: 'POLICY_COVERAGE_NK'
derived_columns:
  ASSESSMENT_BK: 'ASSESSMENT_BK'
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || ASSESSMENT_BK"
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PROPOSAL_BK: 'PROPOSAL_BK'
  PROPOSAL_NK: "'HUB_PROPOSAL|' || PROPOSAL_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  POLICY_COVERAGE_NK: "case when __LNK_POLICY_COVERAGE = 1 then 'LNK_POLICY_COVERAGE|' || COVERAGE_BK || '|' || POLICY_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v17_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
