-- automate_dv.stage() over central view stitch_mxm__v08_location: every hub key and link key the view
-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6).
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v08_location'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY: 'PARTY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
derived_columns:
  LOCATION_BK: 'LOCATION_BK'
  LOCATION_NK: "'HUB_LOCATION|' || LOCATION_BK"
  ORG_UNIT_BK: 'ORG_UNIT_BK'
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || ORG_UNIT_BK"
  PARTY_BK: 'PARTY_BK'
  PARTY_NK: "'HUB_PARTY|' || PARTY_BK"
  PARTY_LOCATION_NK: "case when __LNK_PARTY_LOCATION = 1 then 'LNK_PARTY_LOCATION|' || LOCATION_BK || '|' || PARTY_BK end"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v08_location'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
