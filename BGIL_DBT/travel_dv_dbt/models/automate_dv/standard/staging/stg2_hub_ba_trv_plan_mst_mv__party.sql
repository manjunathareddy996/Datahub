{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_PARTY branch 'BA_TRV_PLAN_MST_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_plan_mst_mv'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'cft_mst_comp_ref'
  PARENT_NK: "'HUB_PARTY|' || (cft_mst_comp_ref)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_TRV_PLAN_MST_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
