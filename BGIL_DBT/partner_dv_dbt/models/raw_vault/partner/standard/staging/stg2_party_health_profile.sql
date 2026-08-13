{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stage() pass for stitch_party_health_profile -- serves SAT_PARTY_HEALTH_PROFILE.
-- PARTY_HKEY hashed once here (namespaced: 'HUB_PARTY|' || raw key).

{%- set yaml_metadata -%}
source_model: 'stitch_party_health_profile'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BODYMASSINDEX'
      - 'HEIGHT'
      - 'MATERNITYSTATUS'
      - 'SMOKERINDICATOR'
      - 'WEIGHT'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
