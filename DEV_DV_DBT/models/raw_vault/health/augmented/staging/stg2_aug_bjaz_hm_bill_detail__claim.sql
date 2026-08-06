{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_CLAIM, table 'BJAZ_HM_BILL_DETAIL'.
-- 6 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_BILL_DETAIL carries a verified HUB_CLAIM key
-- (CLAIM_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_bill_detail'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REF_BILL_ID'
      - 'CLAIMED_AMT'
      - 'TOT_APP_AMTMOU'
      - 'AMT_FRM_PATIENT'
      - 'ROOM_RENT_PERC'
      - 'GRADE'
derived_columns:
  PARENT_BK: 'claim_id'
  PARENT_NK: "'HUB_CLAIM|' || (claim_id)"
  REF_BILL_ID: 'ref_bill_id'
  CLAIMED_AMT: 'claimed_amt'
  TOT_APP_AMTMOU: 'tot_app_amtmou'
  AMT_FRM_PATIENT: 'amt_frm_patient'
  ROOM_RENT_PERC: 'room_rent_perc'
  GRADE: 'grade'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_BILL_DETAIL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
