-- automate_dv.stage() over central view stitch_v05_claim: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v05_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  COVERAGE_HKEY: 'COVERAGE_NK'
  CLAIM_COVERAGE_HKEY: 'CLAIM_COVERAGE_NK'
derived_columns:
  CLAIM_BK: 'CLAIM_BK'
  CLAIM_NK: "'HUB_CLAIM|' || CLAIM_BK"
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  CLAIM_COVERAGE_NK: "case when __LNK_CLAIM_COVERAGE = 1 then 'LNK_CLAIM_COVERAGE|' || CLAIM_BK || '|' || COVERAGE_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
