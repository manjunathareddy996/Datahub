-- automate_dv.stage() over central view stitch_mxm__v01_assessment: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  CLAIM_HKEY: 'CLAIM_NK'
  COVERAGE_HKEY: 'COVERAGE_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  POLICY_HKEY: 'POLICY_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  CLAIM_ASSESSMENT_HKEY: 'CLAIM_ASSESSMENT_NK'
  CLAIM_COVERAGE_HKEY: 'CLAIM_COVERAGE_NK'
  QUOTE_RISK_OBJECT_HKEY: 'QUOTE_RISK_OBJECT_NK'
  RISK_OBJECT_DOCUMENT_HKEY: 'RISK_OBJECT_DOCUMENT_NK'
derived_columns:
  ASSESSMENT_BK: 'ASSESSMENT_BK'
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || ASSESSMENT_BK"
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  DOCUMENT_BK: 'DOCUMENT_BK'
  DOCUMENT_NK: "'HUB_DOCUMENT|' || DOCUMENT_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  QUOTE_BK: 'QUOTE_BK'
  QUOTE_NK: "'HUB_QUOTE|' || QUOTE_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  CLAIM_ASSESSMENT_NK: "case when __LNK_CLAIM_ASSESSMENT = 1 then 'LNK_CLAIM_ASSESSMENT|' || ASSESSMENT_BK || '|' || CLAIM_BK end"
  CLAIM_COVERAGE_NK: "case when __LNK_CLAIM_COVERAGE = 1 then 'LNK_CLAIM_COVERAGE|' || CLAIM_BK || '|' || COVERAGE_BK end"
  QUOTE_RISK_OBJECT_NK: "case when __LNK_QUOTE_RISK_OBJECT = 1 then 'LNK_QUOTE_RISK_OBJECT|' || QUOTE_BK || '|' || RISK_OBJECT_BK end"
  RISK_OBJECT_DOCUMENT_NK: "case when __LNK_RISK_OBJECT_DOCUMENT = 1 then 'LNK_RISK_OBJECT_DOCUMENT|' || DOCUMENT_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v01_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
