{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_ASSESSMENT, table 'BJAZ_HM_DOCTOR_ASSESS'.
-- 3 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_DOCTOR_ASSESS carries a verified HUB_ASSESSMENT key
-- (DOCASESS_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_doctor_assess'
hashed_columns:
  ASSESSMENT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DIAGNOSIS_DETAIL'
      - 'ICD_ID'
      - 'PCS_YN'
derived_columns:
  PARENT_BK: 'docasess_id'
  PARENT_NK: "'HUB_ASSESSMENT|' || (docasess_id)"
  DIAGNOSIS_DETAIL: 'diagnosis_detail'
  ICD_ID: 'icd_id'
  PCS_YN: 'pcs_yn'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_DOCTOR_ASSESS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
