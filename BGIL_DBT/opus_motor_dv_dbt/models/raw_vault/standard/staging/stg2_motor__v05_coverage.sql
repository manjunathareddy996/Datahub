-- automate_dv.stage() over central view stitch_motor__v05_coverage: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v05_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  POLICY_COVERAGE_HKEY: 'POLICY_COVERAGE_NK'
  POLICY_COVERAGE_RISK_HKEY: 'POLICY_COVERAGE_RISK_NK'
  POLICY_RISK_OBJECT_HKEY: 'POLICY_RISK_OBJECT_NK'
derived_columns:
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PRODUCT_BK: 'PRODUCT_BK'
  PRODUCT_NK: "'HUB_PRODUCT|' || PRODUCT_BK"
  RISK_OBJECT_BK: 'RISK_OBJECT_BK'
  RISK_OBJECT_NK: "'HUB_RISK_OBJECT|' || RISK_OBJECT_BK"
  POLICY_COVERAGE_NK: "case when __LNK_POLICY_COVERAGE = 1 then 'LNK_POLICY_COVERAGE|' || COVERAGE_BK || '|' || POLICY_BK end"
  POLICY_COVERAGE_RISK_NK: "case when __LNK_POLICY_COVERAGE_RISK = 1 then 'LNK_POLICY_COVERAGE_RISK|' || COVERAGE_BK || '|' || POLICY_BK || '|' || RISK_OBJECT_BK end"
  POLICY_RISK_OBJECT_NK: "case when __LNK_POLICY_RISK_OBJECT = 1 then 'LNK_POLICY_RISK_OBJECT|' || POLICY_BK || '|' || RISK_OBJECT_BK end"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v05_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
