{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_COVERAGE_DEFINITION, benefit
-- branch 'ADVENTURESPORTBENEFIT' on 'BJAZ_TRV_LOADER_DATA_MV'. Reuses the exact COVERAGE_HKEY
-- formula from stg2_hub_bjaz_trv_loader_data_mv__coverage_adventuresportbenefit.sql.

-- Cover Code: TRV_ADVENTURE_SPORT (Adventure Sport Benefit) -- from the mapper's Benefit Catalog sheet (round 3).

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FREE_COVER_LIMIT'
derived_columns:
  PARENT_BK: "policy_ref || '|' || 'TRV_ADVENTURE_SPORT'"
  PARENT_NK: "'HUB_COVERAGE|' || (policy_ref || '|' || 'TRV_ADVENTURE_SPORT')"
  FREE_COVER_LIMIT: 'adventuresportbenefit'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
