-- automate_dv.stage() over central view stitch_v01_agreement: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  CLAIM_HKEY: 'CLAIM_NK'
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  AGREEMENT_CHANNEL_HKEY: 'AGREEMENT_CHANNEL_NK'
  AGREEMENT_PARTY_HKEY: 'AGREEMENT_PARTY_NK'
  PARTY_CHANNEL_HKEY: 'PARTY_CHANNEL_NK'
  POLICY_CHANNEL_HKEY: 'POLICY_CHANNEL_NK'
  POLICY_DOCUMENT_HKEY: 'POLICY_DOCUMENT_NK'
  PARTY_ROLE_HKEY: 'PARTY_ROLE_NK'
derived_columns:
  AGREEMENT_BK: 'AGREEMENT_BK'
  AGREEMENT_NK: "'HUB_AGREEMENT|' || AGREEMENT_BK"
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  DISTRIBUTION_CHANNEL_BK: 'DISTRIBUTION_CHANNEL_BK'
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK"
  DOCUMENT_BK: 'DOCUMENT_BK'
  DOCUMENT_NK: "'HUB_DOCUMENT|' || DOCUMENT_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  AGREEMENT_CHANNEL_NK: "case when __LNK_AGREEMENT_CHANNEL = 1 then 'LNK_AGREEMENT_CHANNEL|' || AGREEMENT_BK || '|' || DISTRIBUTION_CHANNEL_BK end"
  AGREEMENT_PARTY_NK: "case when __LNK_AGREEMENT_PARTY = 1 then 'LNK_AGREEMENT_PARTY|' || AGREEMENT_BK || '|' || PARTY_BK end"
  PARTY_CHANNEL_NK: "case when __LNK_PARTY_CHANNEL = 1 then 'LNK_PARTY_CHANNEL|' || DISTRIBUTION_CHANNEL_BK || '|' || PARTY_BK end"
  POLICY_CHANNEL_NK: "case when __LNK_POLICY_CHANNEL = 1 then 'LNK_POLICY_CHANNEL|' || DISTRIBUTION_CHANNEL_BK || '|' || POLICY_BK end"
  POLICY_DOCUMENT_NK: "case when __LNK_POLICY_DOCUMENT = 1 then 'LNK_POLICY_DOCUMENT|' || DOCUMENT_BK || '|' || POLICY_BK end"
  PARTY_ROLE_NK: "case when ROLE_TYPE_CODE is not null then 'LNK_PARTY_ROLE|' || PARTY_BK || '|' || ROLE_TYPE_CODE end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
