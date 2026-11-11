-- automate_dv.stage() over central view stitch_v20_party: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v20_party'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  PARTY_ROLE_HKEY: 'PARTY_ROLE_NK'
  POLICY_COVERAGE_HKEY: 'POLICY_COVERAGE_NK'
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
derived_columns:
  COVERAGE_BK: 'COVERAGE_BK'
  COVERAGE_NK: "'HUB_COVERAGE|' || COVERAGE_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  PARTY_ROLE_NK: "case when __LNK_PARTY_ROLE = 1 then 'LNK_PARTY_ROLE|' || PARTY_BK end"
  POLICY_COVERAGE_NK: "case when __LNK_POLICY_COVERAGE = 1 then 'LNK_POLICY_COVERAGE|' || COVERAGE_BK || '|' || POLICY_BK end"
  POLICY_PARTY_NK: "case when __LNK_POLICY_PARTY = 1 then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v20_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
