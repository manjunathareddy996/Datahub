-- automate_dv.stage() over central view stitch_mxm__v03_claim: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  CLAIM_POLICY_HKEY: 'CLAIM_POLICY_NK'
  FINTXN_CLAIM_HKEY: 'FINTXN_CLAIM_NK'
derived_columns:
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  FINANCIAL_TRANSACTION_BK: 'FINANCIAL_TRANSACTION_BK'
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  CLAIM_PARTY_NK: "case when __LNK_CLAIM_PARTY = 1 then 'LNK_CLAIM_PARTY|' || CLAIM_BK || '|' || PARTY_BK end"
  CLAIM_POLICY_NK: "case when __LNK_CLAIM_POLICY = 1 then 'LNK_CLAIM_POLICY|' || CLAIM_BK || '|' || POLICY_BK end"
  FINTXN_CLAIM_NK: "case when __LNK_FINTXN_CLAIM = 1 then 'LNK_FINTXN_CLAIM|' || CLAIM_BK || '|' || FINANCIAL_TRANSACTION_BK end"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
