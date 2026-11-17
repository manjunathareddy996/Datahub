-- automate_dv.stage() over central view stitch_motor__v07_location: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v07_location'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  PARTY_HKEY: 'PARTY_NK'
  PARTY_ROLE_HKEY: 'PARTY_ROLE_NK'
derived_columns:
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  PARTY_ROLE_NK: "case when ROLE_TYPE_CODE is not null then 'LNK_PARTY_ROLE|' || PARTY_BK || '|' || ROLE_TYPE_CODE end"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v07_location'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
