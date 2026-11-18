-- automate_dv.stage() over central view stitch_motor__v21_product: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v21_product'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
  PRODUCT_COVERAGE_HKEY: 'PRODUCT_COVERAGE_NK'
  PROPOSAL_POLICY_HKEY: 'PROPOSAL_POLICY_NK'
  PROPOSAL_PRODUCT_HKEY: 'PROPOSAL_PRODUCT_NK'
derived_columns:
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  PROPOSAL_BK: 'PROPOSAL_BK'
  PROPOSAL_NK: "'HUB_PROPOSAL|' || PROPOSAL_BK"
  POLICY_PRODUCT_NK: "case when __LNK_POLICY_PRODUCT = 1 then 'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK end"
  PRODUCT_COVERAGE_NK: "case when __LNK_PRODUCT_COVERAGE = 1 then 'LNK_PRODUCT_COVERAGE|' || COVERAGE_BK || '|' || PRODUCT_BK end"
  PROPOSAL_POLICY_NK: "case when __LNK_PROPOSAL_POLICY = 1 then 'LNK_PROPOSAL_POLICY|' || POLICY_BK || '|' || PROPOSAL_BK end"
  PROPOSAL_PRODUCT_NK: "case when __LNK_PROPOSAL_PRODUCT = 1 then 'LNK_PROPOSAL_PRODUCT|' || PRODUCT_BK || '|' || PROPOSAL_BK end"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v21_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
