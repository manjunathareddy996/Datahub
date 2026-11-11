-- automate_dv.stage() over central view stitch_v22_policy: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v22_policy'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  POLICY_HKEY: 'POLICY_NK'
derived_columns:
  ASSESSMENT_BK: 'ASSESSMENT_BK'
  ASSESSMENT_NK: "'HUB_ASSESSMENT|' || ASSESSMENT_BK"
  POLICY_BK: 'POLICY_BK'
  POLICY_NK: "'HUB_POLICY|' || POLICY_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v22_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
