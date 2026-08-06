{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_HM_HOSPITAL_MASTER_EXTN'.
-- 5 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_HOSPITAL_MASTER_EXTN carries a verified HUB_PARTY key
-- (HOSID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hospital_master_extn'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INS_DEPT_CONTACT1'
      - 'INS_DEPT_CONTACT2'
      - 'NEFT_STATUS'
      - 'RE_EMPANEL_DATE'
      - 'SPECIAL_REMARKS'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  INS_DEPT_CONTACT1: 'ins_dept_contact1'
  INS_DEPT_CONTACT2: 'ins_dept_contact2'
  NEFT_STATUS: 'neft_status'
  RE_EMPANEL_DATE: 're_empanel_date'
  SPECIAL_REMARKS: 'special_remarks'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
