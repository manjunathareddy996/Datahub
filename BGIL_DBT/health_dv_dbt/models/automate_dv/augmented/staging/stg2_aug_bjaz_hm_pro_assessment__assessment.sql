{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_ASSESSMENT, table 'BJAZ_HM_PRO_ASSESSMENT'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_PRO_ASSESSMENT carries a verified HUB_ASSESSMENT key
-- (ASSESS_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_pro_assessment'
hashed_columns:
  ASSESSMENT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINAL_DIAGNOSIS'
derived_columns:
  PARENT_BK: 'assess_id'
  PARENT_NK: "'HUB_ASSESSMENT|' || (assess_id)"
  FINAL_DIAGNOSIS: 'final_diagnosis'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_PRO_ASSESSMENT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
