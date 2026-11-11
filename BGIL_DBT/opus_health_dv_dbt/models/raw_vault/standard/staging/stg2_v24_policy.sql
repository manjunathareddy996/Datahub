-- automate_dv.stage() over central view stitch_v24_policy: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v24_policy'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  POLICY_COVERAGE_HKEY: 'POLICY_COVERAGE_NK'
  POLICY_PRODUCT_HKEY: 'POLICY_PRODUCT_NK'
  PRODUCT_COVERAGE_HKEY: 'PRODUCT_COVERAGE_NK'
derived_columns:
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  POLICY_COVERAGE_NK: "case when __LNK_POLICY_COVERAGE = 1 then 'LNK_POLICY_COVERAGE|' || COVERAGE_BK || '|' || POLICY_BK end"
  POLICY_PRODUCT_NK: "case when __LNK_POLICY_PRODUCT = 1 then 'LNK_POLICY_PRODUCT|' || POLICY_BK || '|' || PRODUCT_BK end"
  PRODUCT_COVERAGE_NK: "case when __LNK_PRODUCT_COVERAGE = 1 then 'LNK_PRODUCT_COVERAGE|' || COVERAGE_BK || '|' || PRODUCT_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v24_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
