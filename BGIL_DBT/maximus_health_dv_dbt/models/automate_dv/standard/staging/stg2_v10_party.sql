-- automate_dv.stage() over central view stitch_v10_party: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY: 'PARTY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  ORG_UNIT_LOCATION_HKEY: 'ORG_UNIT_LOCATION_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
  PARTY_ORG_UNIT_HKEY: 'PARTY_ORG_UNIT_NK'
  QUOTE_PARTY_HKEY: 'QUOTE_PARTY_NK'
  QUOTE_PRODUCT_HKEY: 'QUOTE_PRODUCT_NK'
  PARTY_ROLE_HKEY: 'PARTY_ROLE_NK'
derived_columns:
  FINANCIAL_TRANSACTION_BK: 'FINANCIAL_TRANSACTION_BK'
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  ORG_UNIT_BK: 'ORG_UNIT_BK'
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || ORG_UNIT_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  QUOTE_BK: 'QUOTE_BK'
  QUOTE_NK: "'HUB_QUOTE|' || QUOTE_BK"
  ORG_UNIT_LOCATION_NK: "case when __LNK_ORG_UNIT_LOCATION = 1 then 'LNK_ORG_UNIT_LOCATION|' || LOCATION_BK || '|' || ORG_UNIT_BK end"
  PARTY_LOCATION_NK: "case when __LNK_PARTY_LOCATION = 1 then 'LNK_PARTY_LOCATION|' || LOCATION_BK || '|' || PARTY_BK end"
  PARTY_ORG_UNIT_NK: "case when __LNK_PARTY_ORG_UNIT = 1 then 'LNK_PARTY_ORG_UNIT|' || ORG_UNIT_BK || '|' || PARTY_BK end"
  QUOTE_PARTY_NK: "case when __LNK_QUOTE_PARTY = 1 then 'LNK_QUOTE_PARTY|' || PARTY_BK || '|' || QUOTE_BK end"
  QUOTE_PRODUCT_NK: "case when __LNK_QUOTE_PRODUCT = 1 then 'LNK_QUOTE_PRODUCT|' || PRODUCT_BK || '|' || QUOTE_BK end"
  PARTY_ROLE_NK: "case when ROLE_TYPE_CODE is not null then 'LNK_PARTY_ROLE|' || PARTY_BK || '|' || ROLE_TYPE_CODE end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
