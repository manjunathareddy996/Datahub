-- automate_dv.stage() over central view stitch_v13_party: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v13_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
derived_columns:
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v13_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
