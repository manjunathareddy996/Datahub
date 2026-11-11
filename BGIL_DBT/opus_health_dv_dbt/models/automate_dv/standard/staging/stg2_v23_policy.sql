-- automate_dv.stage() over central view stitch_v23_policy: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v23_policy'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  FINTXN_POLICY_HKEY: 'FINTXN_POLICY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
  POLICY_ENDORSEMENT_HKEY: 'POLICY_ENDORSEMENT_NK'
  POLICY_LOCATION_HKEY: 'POLICY_LOCATION_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
derived_columns:
  FINANCIAL_TRANSACTION_BK: 'FINANCIAL_TRANSACTION_BK'
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  FINTXN_POLICY_NK: "case when __LNK_FINTXN_POLICY = 1 then 'LNK_FINTXN_POLICY|' || FINANCIAL_TRANSACTION_BK || '|' || POLICY_BK end"
  PARTY_LOCATION_NK: "case when __LNK_PARTY_LOCATION = 1 then 'LNK_PARTY_LOCATION|' || LOCATION_BK || '|' || PARTY_BK end"
  POLICY_ENDORSEMENT_NK: "case when __LNK_POLICY_ENDORSEMENT = 1 then 'LNK_POLICY_ENDORSEMENT|' || POLICY_BK end"
  POLICY_LOCATION_NK: "case when __LNK_POLICY_LOCATION = 1 then 'LNK_POLICY_LOCATION|' || LOCATION_BK || '|' || POLICY_BK end"
  POLICY_PARTY_NK: "case when __LNK_POLICY_PARTY = 1 then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  POLICY_PRODUCT_NK: "case when __LNK_POLICY_PRODUCT = 1 then 'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v23_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
