-- automate_dv.stage() over central view stitch_motor__v03_claim: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v03_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  CLAIM_HKEY: 'CLAIM_NK'
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  CASE_POLICY_HKEY: 'CASE_POLICY_NK'
  CLAIM_CASE_HKEY: 'CLAIM_CASE_NK'
  CLAIM_POLICY_HKEY: 'CLAIM_POLICY_NK'
  CLAIM_RISK_OBJECT_HKEY: 'CLAIM_RISK_OBJECT_NK'
  FINTXN_CLAIM_HKEY: 'FINTXN_CLAIM_NK'
  POLICY_ORG_UNIT_HKEY: 'POLICY_ORG_UNIT_NK'
  POLICY_RISK_OBJECT_HKEY: 'POLICY_RISK_OBJECT_NK'
derived_columns:
  CASE_BK: 'CASE_BK'
  CASE_NK: "'HUB_CASE|' || CASE_BK"
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  FINANCIAL_TRANSACTION_BK: 'FINANCIAL_TRANSACTION_BK'
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  ORG_UNIT_BK: 'ORG_UNIT_BK'
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || ORG_UNIT_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  CASE_POLICY_NK: "case when __LNK_CASE_POLICY = 1 then 'LNK_CASE_POLICY|' || CASE_BK || '|' || POLICY_BK end"
  CLAIM_CASE_NK: "case when __LNK_CLAIM_CASE = 1 then 'LNK_CLAIM_CASE|' || CASE_BK || '|' || CLAIM_BK end"
  CLAIM_POLICY_NK: "case when __LNK_CLAIM_POLICY = 1 then 'LNK_CLAIM_POLICY|' || CLAIM_BK || '|' || POLICY_BK end"
  CLAIM_RISK_OBJECT_NK: "case when __LNK_CLAIM_RISK_OBJECT = 1 then 'LNK_CLAIM_RISK_OBJECT|' || CLAIM_BK || '|' || RISK_OBJECT_BK end"
  FINTXN_CLAIM_NK: "case when __LNK_FINTXN_CLAIM = 1 then 'LNK_FINTXN_CLAIM|' || CLAIM_BK || '|' || FINANCIAL_TRANSACTION_BK end"
  POLICY_ORG_UNIT_NK: "case when __LNK_POLICY_ORG_UNIT = 1 then 'LNK_POLICY_ORG_UNIT|' || ORG_UNIT_BK || '|' || POLICY_BK end"
  POLICY_RISK_OBJECT_NK: "case when __LNK_POLICY_RISK_OBJECT = 1 then 'LNK_POLICY_RISK_OBJECT|' || POLICY_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
