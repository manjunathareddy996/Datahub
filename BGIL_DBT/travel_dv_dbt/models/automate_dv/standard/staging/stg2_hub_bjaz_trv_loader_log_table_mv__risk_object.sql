{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_RISK_OBJECT, table
-- 'BJAZ_TRV_LOADER_LOG_TABLE_MV'. BUILD-SIDE JUDGMENT CALL, not mapper-specified: this
-- table has no MEMBER-prefixed columns in its real schema (confirmed) -- it's a separate,
-- single-traveller source feed, unlike BJAZ_TRV_LOADER_DATA_MV's wide multi-traveller
-- shape. With no dedicated risk/vehicle identifier column, this build synthesizes one
-- HUB_RISK_OBJECT node per policy by reusing POLICYNUMBER (the same raw value as this
-- table's own HUB_POLICY key, just re-namespaced) -- stable and logically justified
-- (single-traveller feed = 1 policy = 1 risk object), but not explicitly confirmed by the
-- mapper. Flagged in docs/MAPPER_QUESTIONS_TRAVEL.md.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  RISK_OBJECT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'policynumber'
  PARENT_NK: "'HUB_RISK_OBJECT|' || (policynumber)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
