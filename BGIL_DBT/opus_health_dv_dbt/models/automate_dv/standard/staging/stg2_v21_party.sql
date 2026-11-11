-- automate_dv.stage() over central view stitch_v21_party: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v21_party'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  PARTY_CHANNEL_HKEY: 'PARTY_CHANNEL_NK'
  PARTY_DOCUMENT_HKEY: 'PARTY_DOCUMENT_NK'
  POLICY_CHANNEL_HKEY: 'POLICY_CHANNEL_NK'
  POLICY_DOCUMENT_HKEY: 'POLICY_DOCUMENT_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
  POLICY_RISK_OBJECT_HKEY: 'POLICY_RISK_OBJECT_NK'
  RISK_OBJECT_DOCUMENT_HKEY: 'RISK_OBJECT_DOCUMENT_NK'
  RISK_OBJECT_PARTY_HKEY: 'RISK_OBJECT_PARTY_NK'
derived_columns:
  DISTRIBUTION_CHANNEL_BK: 'DISTRIBUTION_CHANNEL_BK'
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK"
  DOCUMENT_BK: 'DOCUMENT_BK'
  DOCUMENT_NK: "'HUB_DOCUMENT|' || DOCUMENT_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  PARTY_CHANNEL_NK: "case when __LNK_PARTY_CHANNEL = 1 then 'LNK_PARTY_CHANNEL|' || DISTRIBUTION_CHANNEL_BK || '|' || PARTY_BK end"
  PARTY_DOCUMENT_NK: "case when __LNK_PARTY_DOCUMENT = 1 then 'LNK_PARTY_DOCUMENT|' || DOCUMENT_BK || '|' || PARTY_BK end"
  POLICY_CHANNEL_NK: "case when __LNK_POLICY_CHANNEL = 1 then 'LNK_POLICY_CHANNEL|' || DISTRIBUTION_CHANNEL_BK || '|' || POLICY_BK end"
  POLICY_DOCUMENT_NK: "case when __LNK_POLICY_DOCUMENT = 1 then 'LNK_POLICY_DOCUMENT|' || DOCUMENT_BK || '|' || POLICY_BK end"
  POLICY_PARTY_NK: "case when __LNK_POLICY_PARTY = 1 then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  POLICY_PRODUCT_NK: "case when __LNK_POLICY_PRODUCT = 1 then 'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK end"
  POLICY_RISK_OBJECT_NK: "case when __LNK_POLICY_RISK_OBJECT = 1 then 'LNK_POLICY_RISK_OBJECT|' || POLICY_BK || '|' || RISK_OBJECT_BK end"
  RISK_OBJECT_DOCUMENT_NK: "case when __LNK_RISK_OBJECT_DOCUMENT = 1 then 'LNK_RISK_OBJECT_DOCUMENT|' || DOCUMENT_BK || '|' || RISK_OBJECT_BK end"
  RISK_OBJECT_PARTY_NK: "case when __LNK_RISK_OBJECT_PARTY = 1 then 'LNK_RISK_OBJECT_PARTY|' || PARTY_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v21_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
