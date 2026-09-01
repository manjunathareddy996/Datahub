{{ config(materialized='view') }}

-- TRAVEL AUGMENTED per-table stage() for SAT_AUG_RISK_PERSON_TRAVEL, table
-- 'BJAZ_TRV_LOADER_DATA_MV', fanned out to traveller MEMBER1. MODEOFTRANSPORT/
-- ALTITUDE are whole-policy facts (no MEMBERn prefix) -- same value replicated
-- across every traveller's HUB_RISK_OBJECT row, per the mapper's fan-out
-- instruction (docs/MAPPER_QUESTIONS_TRAVEL.md / MAPPER_REPLIES_TRAVEL.md).

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  RISK_OBJECT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MODE_OF_TRANSPORT'
      - 'ALTITUDE_LIMIT'
derived_columns:
  PARENT_BK: 'policy_ref || '|member1''
  PARENT_NK: "'HUB_RISK_OBJECT|' || (policy_ref || '|member1')"
  MODE_OF_TRANSPORT: 'modeoftransport'
  ALTITUDE_LIMIT: 'altitude'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
