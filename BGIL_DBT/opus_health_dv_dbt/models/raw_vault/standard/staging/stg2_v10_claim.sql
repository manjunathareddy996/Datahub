-- automate_dv.stage() over central view stitch_v10_claim: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  CLAIM_HKEY: 'CLAIM_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  CASE_DOCUMENT_HKEY: 'CASE_DOCUMENT_NK'
  CASE_PARTY_HKEY: 'CASE_PARTY_NK'
  CLAIM_CASE_HKEY: 'CLAIM_CASE_NK'
  CLAIM_DOCUMENT_HKEY: 'CLAIM_DOCUMENT_NK'
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  CLAIM_POLICY_HKEY: 'CLAIM_POLICY_NK'
  PARTY_DOCUMENT_HKEY: 'PARTY_DOCUMENT_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
derived_columns:
  CASE_BK: 'CASE_BK'
  CASE_NK: "'HUB_CASE|' || CASE_BK"
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  DOCUMENT_BK: 'DOCUMENT_BK'
  DOCUMENT_NK: "'HUB_DOCUMENT|' || DOCUMENT_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  CASE_DOCUMENT_NK: "case when __LNK_CASE_DOCUMENT = 1 then 'LNK_CASE_DOCUMENT|' || CASE_BK || '|' || DOCUMENT_BK end"
  CASE_PARTY_NK: "case when __LNK_CASE_PARTY = 1 then 'LNK_CASE_PARTY|' || CASE_BK || '|' || PARTY_BK end"
  CLAIM_CASE_NK: "case when __LNK_CLAIM_CASE = 1 then 'LNK_CLAIM_CASE|' || CASE_BK || '|' || CLAIM_BK end"
  CLAIM_DOCUMENT_NK: "case when __LNK_CLAIM_DOCUMENT = 1 then 'LNK_CLAIM_DOCUMENT|' || CLAIM_BK || '|' || DOCUMENT_BK end"
  CLAIM_PARTY_NK: "case when __LNK_CLAIM_PARTY = 1 then 'LNK_CLAIM_PARTY|' || CLAIM_BK || '|' || PARTY_BK end"
  CLAIM_POLICY_NK: "case when __LNK_CLAIM_POLICY = 1 then 'LNK_CLAIM_POLICY|' || CLAIM_BK || '|' || POLICY_BK end"
  PARTY_DOCUMENT_NK: "case when __LNK_PARTY_DOCUMENT = 1 then 'LNK_PARTY_DOCUMENT|' || DOCUMENT_BK || '|' || PARTY_BK end"
  POLICY_PARTY_NK: "case when __LNK_POLICY_PARTY = 1 then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
