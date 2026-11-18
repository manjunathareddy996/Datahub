-- automate_dv.stage() over central view stitch_motor__v02_claim: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  CLAIM_HKEY: 'CLAIM_NK'
  DOCUMENT_HKEY: 'DOCUMENT_NK'
  LOSS_EVENT_HKEY: 'LOSS_EVENT_NK'
  CLAIM_DOCUMENT_HKEY: 'CLAIM_DOCUMENT_NK'
derived_columns:
  CASE_BK: 'CASE_BK'
  CASE_NK: "'HUB_CASE|' || CASE_BK"
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  DOCUMENT_BK: 'DOCUMENT_BK'
  DOCUMENT_NK: "'HUB_DOCUMENT|' || DOCUMENT_BK"
  LOSS_EVENT_BK: 'LOSS_EVENT_BK'
  LOSS_EVENT_NK: "'HUB_LOSS_EVENT|' || LOSS_EVENT_BK"
  CLAIM_DOCUMENT_NK: "case when __LNK_CLAIM_DOCUMENT = 1 then 'LNK_CLAIM_DOCUMENT|' || CLAIM_BK || '|' || DOCUMENT_BK end"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
