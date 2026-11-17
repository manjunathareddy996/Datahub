-- automate_dv.stage() over central view stitch_motor__v01_claim: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  CLAIM_HKEY: 'CLAIM_NK'
  LOSS_EVENT_HKEY: 'LOSS_EVENT_NK'
  POLICY_HKEY: 'POLICY_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  CLAIM_ASSESSMENT_HKEY: 'CLAIM_ASSESSMENT_NK'
  CLAIM_LOSS_EVENT_HKEY: 'CLAIM_LOSS_EVENT_NK'
  CLAIM_POLICY_HKEY: 'CLAIM_POLICY_NK'
  CLAIM_RISK_OBJECT_HKEY: 'CLAIM_RISK_OBJECT_NK'
  LOSS_EVENT_RISK_OBJECT_HKEY: 'LOSS_EVENT_RISK_OBJECT_NK'
  POLICY_RISK_OBJECT_HKEY: 'POLICY_RISK_OBJECT_NK'
  RISK_OBJECT_ASSESSMENT_HKEY: 'RISK_OBJECT_ASSESSMENT_NK'
derived_columns:
  ASSESSMENT_BK: 'ASSESSMENT_BK'
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || ASSESSMENT_BK"
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  LOSS_EVENT_BK: 'LOSS_EVENT_BK'
  LOSS_EVENT_NK: "'HUB_LOSS_EVENT|' || LOSS_EVENT_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  CLAIM_ASSESSMENT_NK: "case when __LNK_CLAIM_ASSESSMENT = 1 then 'LNK_CLAIM_ASSESSMENT|' || ASSESSMENT_BK || '|' || CLAIM_BK end"
  CLAIM_LOSS_EVENT_NK: "case when __LNK_CLAIM_LOSS_EVENT = 1 then 'LNK_CLAIM_LOSS_EVENT|' || CLAIM_BK || '|' || LOSS_EVENT_BK end"
  CLAIM_POLICY_NK: "case when __LNK_CLAIM_POLICY = 1 then 'LNK_CLAIM_POLICY|' || CLAIM_BK || '|' || POLICY_BK end"
  CLAIM_RISK_OBJECT_NK: "case when __LNK_CLAIM_RISK_OBJECT = 1 then 'LNK_CLAIM_RISK_OBJECT|' || CLAIM_BK || '|' || RISK_OBJECT_BK end"
  LOSS_EVENT_RISK_OBJECT_NK: "case when __LNK_LOSS_EVENT_RISK_OBJECT = 1 then 'LNK_LOSS_EVENT_RISK_OBJECT|' || LOSS_EVENT_BK || '|' || RISK_OBJECT_BK end"
  POLICY_RISK_OBJECT_NK: "case when __LNK_POLICY_RISK_OBJECT = 1 then 'LNK_POLICY_RISK_OBJECT|' || POLICY_BK || '|' || RISK_OBJECT_BK end"
  RISK_OBJECT_ASSESSMENT_NK: "case when __LNK_RISK_OBJECT_ASSESSMENT = 1 then 'LNK_RISK_OBJECT_ASSESSMENT|' || ASSESSMENT_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v01_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
