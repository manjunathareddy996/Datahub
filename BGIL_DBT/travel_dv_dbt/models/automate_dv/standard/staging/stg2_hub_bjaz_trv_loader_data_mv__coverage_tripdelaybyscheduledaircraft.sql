{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_COVERAGE, benefit branch
-- 'TRIPDELAYBYSCHEDULEDAIRCRAFT' on 'BJAZ_TRV_LOADER_DATA_MV'. Wide-benefit unpivot (round 2, Correction
-- C) -- each Free Cover Limit column is its own coverage instance. Key =
-- POLICY_REF || the real Cover Code from the mapper's Benefit Catalog sheet (round 3;
-- an earlier version of this file used the raw column name as a placeholder code).

-- Cover Code: TRV_TRIP_DELAY (Trip Delay By Scheduled Aircraft) -- from the mapper's Benefit Catalog sheet (round 3).

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: "policy_ref || '|' || 'TRV_TRIP_DELAY'"
  PARENT_NK: "'HUB_COVERAGE|' || (policy_ref || '|' || 'TRV_TRIP_DELAY')"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
