{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_CLAIM, table 'BJAZ_HM_BILL_DETAIL_OCR'.
-- 5 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_BILL_DETAIL_OCR carries a verified HUB_CLAIM key
-- (CLAIM_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_bill_detail_ocr'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAIMED_AMT'
      - 'ADD_STATUS'
      - 'REF_BILL_ID'
      - 'AVAILED_ROOM_RENT_PER_DAY'
      - 'ROOM_RENT_PERC'
derived_columns:
  PARENT_BK: 'claim_id'
  PARENT_NK: "'HUB_CLAIM|' || (claim_id)"
  CLAIMED_AMT: 'claimed_amt'
  ADD_STATUS: 'add_status'
  REF_BILL_ID: 'ref_bill_id'
  AVAILED_ROOM_RENT_PER_DAY: 'availed_room_rent_per_day'
  ROOM_RENT_PERC: 'room_rent_perc'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_BILL_DETAIL_OCR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
