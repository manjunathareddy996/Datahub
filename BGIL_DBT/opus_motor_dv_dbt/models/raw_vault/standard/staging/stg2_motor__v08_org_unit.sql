-- automate_dv.stage() over central view stitch_motor__v08_org_unit: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v08_org_unit'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  FINTXN_POLICY_HKEY: 'FINTXN_POLICY_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
  POLICY_RISK_OBJECT_HKEY: 'POLICY_RISK_OBJECT_NK'
derived_columns:
  FINANCIAL_TRANSACTION_BK: 'FINANCIAL_TRANSACTION_BK'
  FINANCIAL_TRANSACTION_NK: "'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK"
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  ORG_UNIT_BK: 'ORG_UNIT_BK'
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || ORG_UNIT_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  FINTXN_POLICY_NK: "case when __LNK_FINTXN_POLICY = 1 then 'LNK_FINTXN_POLICY|' || FINANCIAL_TRANSACTION_BK || '|' || POLICY_BK end"
  POLICY_PRODUCT_NK: "case when __LNK_POLICY_PRODUCT = 1 then 'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK end"
  POLICY_RISK_OBJECT_NK: "case when __LNK_POLICY_RISK_OBJECT = 1 then 'LNK_POLICY_RISK_OBJECT|' || POLICY_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v08_org_unit'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
