{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_AGREEMENT, table 'BJAZ_HM_HOSP_MASTER_EXTN1'.
-- 19 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_HOSP_MASTER_EXTN1 carries a verified HUB_AGREEMENT key
-- (HOSID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hosp_master_extn1'
hashed_columns:
  AGREEMENT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'STARTDATE1'
      - 'ENDDATE1'
      - 'REMARK1'
      - 'STARTDATE2'
      - 'ENDDATE2'
      - 'REMARK2'
      - 'NONCHMSURG'
      - 'STARTDATE3'
      - 'ENDDATE3'
      - 'REMARK3'
      - 'COSTNEGO'
      - 'STARTDATE4'
      - 'ENDDATE4'
      - 'REMARK4'
      - 'EARLYPAYREMARK'
      - 'CBBILLRECTIME'
      - 'TATRANGE'
      - 'CBDISCREMARK'
      - 'CBDISCBUSFIG'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_AGREEMENT|' || (hosid)"
  STARTDATE1: 'startdate1'
  ENDDATE1: 'enddate1'
  REMARK1: 'remark1'
  STARTDATE2: 'startdate2'
  ENDDATE2: 'enddate2'
  REMARK2: 'remark2'
  NONCHMSURG: 'nonchmsurg'
  STARTDATE3: 'startdate3'
  ENDDATE3: 'enddate3'
  REMARK3: 'remark3'
  COSTNEGO: 'costnego'
  STARTDATE4: 'startdate4'
  ENDDATE4: 'enddate4'
  REMARK4: 'remark4'
  EARLYPAYREMARK: 'earlypayremark'
  CBBILLRECTIME: 'cbbillrectime'
  TATRANGE: 'tatrange'
  CBDISCREMARK: 'cbdiscremark'
  CBDISCBUSFIG: 'cbdiscbusfig'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSP_MASTER_EXTN1'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
