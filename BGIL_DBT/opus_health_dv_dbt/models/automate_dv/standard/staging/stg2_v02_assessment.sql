-- automate_dv.stage() over central view stitch_v02_assessment: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  CASE_HKEY: 'CASE_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  ASSESSMENT_PARTY_HKEY: 'ASSESSMENT_PARTY_NK'
  CASE_PARTY_HKEY: 'CASE_PARTY_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
  QUOTE_PRODUCT_HKEY: 'QUOTE_PRODUCT_NK'
derived_columns:
  ASSESSMENT_BK: 'ASSESSMENT_BK'
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || ASSESSMENT_BK"
  CASE_BK: 'CASE_BK'
  CASE_NK: "'HUB_CASE|' || CASE_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  QUOTE_BK: 'QUOTE_BK'
  QUOTE_NK: "'HUB_QUOTE|' || QUOTE_BK"
  ASSESSMENT_PARTY_NK: "case when __LNK_ASSESSMENT_PARTY = 1 then 'LNK_ASSESSMENT_PARTY|' || ASSESSMENT_BK || '|' || PARTY_BK end"
  CASE_PARTY_NK: "case when __LNK_CASE_PARTY = 1 then 'LNK_CASE_PARTY|' || CASE_BK || '|' || PARTY_BK end"
  POLICY_PRODUCT_NK: "case when __LNK_POLICY_PRODUCT = 1 then 'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK end"
  QUOTE_PRODUCT_NK: "case when __LNK_QUOTE_PRODUCT = 1 then 'LNK_QUOTE_PRODUCT|' || PRODUCT_BK || '|' || QUOTE_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
