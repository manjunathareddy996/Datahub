{{ config(materialized='view') }}

-- DEMO: stg2 for stitched sat_a_b_stitched.
-- ONE hashdiff over the combined row (phone_1, phone_2) — single timeline, no interleaving.
-- PARTY_HKEY hashed from namespaced NK: 'HUB_PARTY|' || parent_bk

{%- set yaml_metadata -%}
source_model: 'stitch_a_b'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PHONE_1'
      - 'PHONE_2'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
