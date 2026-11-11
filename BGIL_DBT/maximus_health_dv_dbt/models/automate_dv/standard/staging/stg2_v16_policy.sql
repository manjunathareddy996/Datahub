-- automate_dv.stage() over central view stitch_v16_policy: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  COVERAGE_HKEY: 'COVERAGE_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
  PARTY_ROLE_HKEY: 'PARTY_ROLE_NK'
derived_columns:
  ASSESSMENT_BK: 'ASSESSMENT_BK'
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || ASSESSMENT_BK"
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  PROPOSAL_BK: 'PROPOSAL_BK'
  PROPOSAL_NK: "'HUB_PROPOSAL|' || PROPOSAL_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  POLICY_PARTY_NK: "case when __LNK_POLICY_PARTY = 1 then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  PARTY_ROLE_NK: "case when ROLE_TYPE_CODE is not null then 'LNK_PARTY_ROLE|' || PARTY_BK || '|' || ROLE_TYPE_CODE end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
