-- automate_dv.stage() over central view stitch_motor__v22_quote: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v22_quote'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  QUOTE_HKEY: 'QUOTE_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  PROPOSAL_RISK_OBJECT_HKEY: 'PROPOSAL_RISK_OBJECT_NK'
  QUOTE_PROPOSAL_HKEY: 'QUOTE_PROPOSAL_NK'
  QUOTE_RISK_OBJECT_HKEY: 'QUOTE_RISK_OBJECT_NK'
  RISK_OBJECT_LOCATION_HKEY: 'RISK_OBJECT_LOCATION_NK'
derived_columns:
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  PROPOSAL_BK: 'PROPOSAL_BK'
  PROPOSAL_NK: "'HUB_PROPOSAL|' || PROPOSAL_BK"
  QUOTE_BK: 'QUOTE_BK'
  QUOTE_NK: "'HUB_QUOTE|' || QUOTE_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  PROPOSAL_RISK_OBJECT_NK: "case when __LNK_PROPOSAL_RISK_OBJECT = 1 then 'LNK_PROPOSAL_RISK_OBJECT|' || PROPOSAL_BK || '|' || RISK_OBJECT_BK end"
  QUOTE_PROPOSAL_NK: "case when __LNK_QUOTE_PROPOSAL = 1 then 'LNK_QUOTE_PROPOSAL|' || PROPOSAL_BK || '|' || QUOTE_BK end"
  QUOTE_RISK_OBJECT_NK: "case when __LNK_QUOTE_RISK_OBJECT = 1 then 'LNK_QUOTE_RISK_OBJECT|' || QUOTE_BK || '|' || RISK_OBJECT_BK end"
  RISK_OBJECT_LOCATION_NK: "case when __LNK_RISK_OBJECT_LOCATION = 1 then 'LNK_RISK_OBJECT_LOCATION|' || LOCATION_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v22_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
