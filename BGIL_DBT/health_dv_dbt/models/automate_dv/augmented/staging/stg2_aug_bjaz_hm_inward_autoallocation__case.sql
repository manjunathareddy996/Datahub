{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_CASE, table 'BJAZ_HM_INWARD_AUTOALLOCATION'.
-- 2 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_INWARD_AUTOALLOCATION carries a verified HUB_CASE key
-- (ALLOCATE_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_inward_autoallocation'
hashed_columns:
  CASE_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ALLOCATE_FLAG'
      - 'ALLOCATE_ON'
derived_columns:
  PARENT_BK: 'allocate_id'
  PARENT_NK: "'HUB_CASE|' || (allocate_id)"
  ALLOCATE_FLAG: 'allocate_flag'
  ALLOCATE_ON: 'allocate_on'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_INWARD_AUTOALLOCATION'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
