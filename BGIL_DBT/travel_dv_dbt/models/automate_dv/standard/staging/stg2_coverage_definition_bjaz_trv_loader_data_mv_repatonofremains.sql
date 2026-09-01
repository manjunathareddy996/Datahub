{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_COVERAGE_DEFINITION, benefit
-- branch 'REPATONOFREMAINS' on 'BJAZ_TRV_LOADER_DATA_MV'. Reuses the exact COVERAGE_HKEY
-- formula from stg2_hub_bjaz_trv_loader_data_mv__coverage_repatonofremains.sql.

-- Cover Code: TRV_REPAT_REMAINS (Repatriation Of Remains) -- from the mapper's Benefit Catalog sheet (round 3).

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FREE_COVER_LIMIT'
derived_columns:
  PARENT_BK: "policy_ref || '|' || 'TRV_REPAT_REMAINS'"
  PARENT_NK: "'HUB_COVERAGE|' || (policy_ref || '|' || 'TRV_REPAT_REMAINS')"
  FREE_COVER_LIMIT: 'repatonofremains'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
