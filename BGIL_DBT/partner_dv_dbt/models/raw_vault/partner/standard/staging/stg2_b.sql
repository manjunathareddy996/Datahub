{{ config(materialized='view') }}

-- STG2_B: hash key + hashdiff generation for TABLE_B -> SAT_A_B
-- PARTY_HKEY hashed from namespaced NK: 'HUB_PARTY|' || id
-- HASHDIFF over payload columns: PHONE_1, PHONE_2
-- LOAD_DATETIME mapped to real business timestamp (updated_at), not CURRENT_TIMESTAMP()

{%- set yaml_metadata -%}
source_model: 'stg_b'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PHONE_1'
      - 'PHONE_2'
derived_columns:
  PARENT_BK: 'id'
  PARTY_NK: "'HUB_PARTY|' || id"
  LOAD_DATETIME: 'updated_at'
  RECORD_SOURCE: '!TABLE_B'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}