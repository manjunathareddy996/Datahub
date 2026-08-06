{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BA_HCP_DT_PREMIUM'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_DT_PREMIUM carries a verified HUB_PARTY key
-- (USER_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_premium'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMP_NO'
derived_columns:
  PARENT_BK: 'user_id'
  PARENT_NK: "'HUB_PARTY|' || (user_id)"
  EMP_NO: 'emp_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_PREMIUM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
