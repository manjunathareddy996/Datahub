{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_ASSESSMENT, table 'BA_HCP_PP_MEM_DTLS'.
-- 5 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_PP_MEM_DTLS carries a verified HUB_ASSESSMENT key
-- (SCRUTINY_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_pp_mem_dtls'
hashed_columns:
  ASSESSMENT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PAY_TYPE'
      - 'SUB_STATUS_CODE'
      - 'APP_TIME'
      - 'RESCHEDULE_DATE'
      - 'RESCHEDULE_TIME'
derived_columns:
  PARENT_BK: 'scrutiny_no'
  PARENT_NK: "'HUB_ASSESSMENT|' || (scrutiny_no)"
  PAY_TYPE: 'pay_type'
  SUB_STATUS_CODE: 'sub_status_code'
  APP_TIME: 'app_time'
  RESCHEDULE_DATE: 'reschedule_date'
  RESCHEDULE_TIME: 'reschedule_time'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PP_MEM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
