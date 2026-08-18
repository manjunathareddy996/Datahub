{{ config(materialized='view') }}

-- STG2_A: hash key + hashdiff generation for TABLE_A -> SAT_A_B
-- PARTY_HKEY hashed from namespaced NK: 'HUB_PARTY|' || id
-- HASHDIFF over payload columns: PHONE_1 (only column A contributes)
-- LOAD_DATETIME mapped to real business timestamp (updated_at), not CURRENT_TIMESTAMP()

{%- set yaml_metadata -%}
source_model: 'stg_a'
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
  PHONE_2: '!NULL'
  LOAD_DATETIME: 'updated_at'
  RECORD_SOURCE: '!TABLE_A'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
