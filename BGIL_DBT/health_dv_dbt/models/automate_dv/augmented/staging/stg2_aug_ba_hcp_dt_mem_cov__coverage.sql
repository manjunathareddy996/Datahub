{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_COVERAGE, table 'BA_HCP_DT_MEM_COV'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_DT_MEM_COV carries a verified HUB_COVERAGE key
-- (HCP_SEQNO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_mem_cov'
hashed_columns:
  COVERAGE_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREM_BASE_COVER'
derived_columns:
  PARENT_BK: 'hcp_seqno'
  PARENT_NK: "'HUB_COVERAGE|' || (hcp_seqno)"
  PREM_BASE_COVER: 'prem_base_cover'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_MEM_COV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
