{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PROPOSAL, table 'BJAZ_GP_HOSPITAL_CASH'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_GP_HOSPITAL_CASH carries a verified HUB_PROPOSAL key
-- (REFERENCE_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_gp_hospital_cash'
hashed_columns:
  PROPOSAL_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BA_LEAD_NO'
derived_columns:
  PARENT_BK: 'reference_id'
  PARENT_NK: "'HUB_PROPOSAL|' || (reference_id)"
  BA_LEAD_NO: 'ba_lead_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GP_HOSPITAL_CASH'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
