{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_CLAIM, table 'BJAZ_HAT_OCR_BILL_DETAILS'.
-- 10 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HAT_OCR_BILL_DETAILS carries a verified HUB_CLAIM key
-- (CASE_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hat_ocr_bill_details'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAIMED_AMOUNT'
      - 'LEVEL1'
      - 'LEVEL2'
      - 'LEVEL3'
      - 'I3_PARTICULAR_ID'
      - 'PARTICULAR'
      - 'PRICE'
      - 'UNIT'
      - 'BILLHEAD'
      - 'LEVEL5'
derived_columns:
  PARENT_BK: 'case_id'
  PARENT_NK: "'HUB_CLAIM|' || (case_id)"
  CLAIMED_AMOUNT: 'claimed_amount'
  LEVEL1: 'level1'
  LEVEL2: 'level2'
  LEVEL3: 'level3'
  I3_PARTICULAR_ID: 'i3_particular_id'
  PARTICULAR: 'particular'
  PRICE: 'price'
  UNIT: 'unit'
  BILLHEAD: 'billhead'
  LEVEL5: 'level5'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HAT_OCR_BILL_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
