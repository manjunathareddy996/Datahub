-- automate_dv.stage() over central view stitch_motor__v12_policy: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v12_policy'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  AGREEMENT_CHANNEL_HKEY: 'AGREEMENT_CHANNEL_NK'
  CHANNEL_ORG_UNIT_HKEY: 'CHANNEL_ORG_UNIT_NK'
  POLICY_CHANNEL_HKEY: 'POLICY_CHANNEL_NK'
  POLICY_LOCATION_HKEY: 'POLICY_LOCATION_NK'
  POLICY_ORG_UNIT_HKEY: 'POLICY_ORG_UNIT_NK'
  POLICY_RISK_OBJECT_HKEY: 'POLICY_RISK_OBJECT_NK'
  RISK_OBJECT_LOCATION_HKEY: 'RISK_OBJECT_LOCATION_NK'
derived_columns:
  AGREEMENT_BK: 'AGREEMENT_BK'
  AGREEMENT_NK: "'HUB_AGREEMENT|' || AGREEMENT_BK"
  DISTRIBUTION_CHANNEL_BK: 'DISTRIBUTION_CHANNEL_BK'
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || DISTRIBUTION_CHANNEL_BK"
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  ORG_UNIT_BK: 'ORG_UNIT_BK'
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || ORG_UNIT_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  AGREEMENT_CHANNEL_NK: "case when __LNK_AGREEMENT_CHANNEL = 1 then 'LNK_AGREEMENT_CHANNEL|' || AGREEMENT_BK || '|' || DISTRIBUTION_CHANNEL_BK end"
  CHANNEL_ORG_UNIT_NK: "case when __LNK_CHANNEL_ORG_UNIT = 1 then 'LNK_CHANNEL_ORG_UNIT|' || DISTRIBUTION_CHANNEL_BK || '|' || ORG_UNIT_BK end"
  POLICY_CHANNEL_NK: "case when __LNK_POLICY_CHANNEL = 1 then 'LNK_POLICY_CHANNEL|' || DISTRIBUTION_CHANNEL_BK || '|' || POLICY_BK end"
  POLICY_LOCATION_NK: "case when __LNK_POLICY_LOCATION = 1 then 'LNK_POLICY_LOCATION|' || LOCATION_BK || '|' || POLICY_BK end"
  POLICY_ORG_UNIT_NK: "case when __LNK_POLICY_ORG_UNIT = 1 then 'LNK_POLICY_ORG_UNIT|' || ORG_UNIT_BK || '|' || POLICY_BK end"
  POLICY_RISK_OBJECT_NK: "case when __LNK_POLICY_RISK_OBJECT = 1 then 'LNK_POLICY_RISK_OBJECT|' || POLICY_BK || '|' || RISK_OBJECT_BK end"
  RISK_OBJECT_LOCATION_NK: "case when __LNK_RISK_OBJECT_LOCATION = 1 then 'LNK_RISK_OBJECT_LOCATION|' || LOCATION_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
