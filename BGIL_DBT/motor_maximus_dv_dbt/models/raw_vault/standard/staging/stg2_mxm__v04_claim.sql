-- automate_dv.stage() over central view stitch_mxm__v04_claim: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  CLAIM_POLICY_HKEY: 'CLAIM_POLICY_NK'
  CLAIM_RISK_OBJECT_HKEY: 'CLAIM_RISK_OBJECT_NK'
  POLICY_ORG_UNIT_HKEY: 'POLICY_ORG_UNIT_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
  POLICY_RISK_OBJECT_HKEY: 'POLICY_RISK_OBJECT_NK'
derived_columns:
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  ORG_UNIT_BK: 'ORG_UNIT_BK'
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || ORG_UNIT_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  QUOTE_BK: 'QUOTE_BK'
  QUOTE_NK: "'HUB_QUOTE|' || QUOTE_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  CLAIM_PARTY_NK: "case when __LNK_CLAIM_PARTY = 1 then 'LNK_CLAIM_PARTY|' || CLAIM_BK || '|' || PARTY_BK end"
  CLAIM_POLICY_NK: "case when __LNK_CLAIM_POLICY = 1 then 'LNK_CLAIM_POLICY|' || CLAIM_BK || '|' || POLICY_BK end"
  CLAIM_RISK_OBJECT_NK: "case when __LNK_CLAIM_RISK_OBJECT = 1 then 'LNK_CLAIM_RISK_OBJECT|' || CLAIM_BK || '|' || RISK_OBJECT_BK end"
  POLICY_ORG_UNIT_NK: "case when __LNK_POLICY_ORG_UNIT = 1 then 'LNK_POLICY_ORG_UNIT|' || ORG_UNIT_BK || '|' || POLICY_BK end"
  POLICY_PRODUCT_NK: "case when __LNK_POLICY_PRODUCT = 1 then 'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK end"
  POLICY_RISK_OBJECT_NK: "case when __LNK_POLICY_RISK_OBJECT = 1 then 'LNK_POLICY_RISK_OBJECT|' || POLICY_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
