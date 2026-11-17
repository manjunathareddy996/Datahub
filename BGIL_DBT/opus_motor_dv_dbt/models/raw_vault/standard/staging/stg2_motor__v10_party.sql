-- automate_dv.stage() over central view stitch_motor__v10_party: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
  POLICY_LOCATION_HKEY: 'POLICY_LOCATION_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
  PROPOSAL_ASSESSMENT_HKEY: 'PROPOSAL_ASSESSMENT_NK'
  PROPOSAL_PARTY_HKEY: 'PROPOSAL_PARTY_NK'
  PROPOSAL_POLICY_HKEY: 'PROPOSAL_POLICY_NK'
  PROPOSAL_PRODUCT_HKEY: 'PROPOSAL_PRODUCT_NK'
derived_columns:
  ASSESSMENT_BK: 'ASSESSMENT_BK'
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || ASSESSMENT_BK"
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
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
  PARTY_LOCATION_NK: "case when __LNK_PARTY_LOCATION = 1 then 'LNK_PARTY_LOCATION|' || LOCATION_BK || '|' || PARTY_BK end"
  POLICY_LOCATION_NK: "case when __LNK_POLICY_LOCATION = 1 then 'LNK_POLICY_LOCATION|' || LOCATION_BK || '|' || POLICY_BK end"
  POLICY_PARTY_NK: "case when __LNK_POLICY_PARTY = 1 then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  POLICY_PRODUCT_NK: "case when __LNK_POLICY_PRODUCT = 1 then 'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK end"
  PROPOSAL_ASSESSMENT_NK: "case when __LNK_PROPOSAL_ASSESSMENT = 1 then 'LNK_PROPOSAL_ASSESSMENT|' || ASSESSMENT_BK || '|' || PROPOSAL_BK end"
  PROPOSAL_PARTY_NK: "case when __LNK_PROPOSAL_PARTY = 1 then 'LNK_PROPOSAL_PARTY|' || PARTY_BK || '|' || PROPOSAL_BK end"
  PROPOSAL_POLICY_NK: "case when __LNK_PROPOSAL_POLICY = 1 then 'LNK_PROPOSAL_POLICY|' || POLICY_BK || '|' || PROPOSAL_BK end"
  PROPOSAL_PRODUCT_NK: "case when __LNK_PROPOSAL_PRODUCT = 1 then 'LNK_PROPOSAL_PRODUCT|' || PRODUCT_BK || '|' || PROPOSAL_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
