{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_CLAIM, table 'BJAZ_HM_BILL_CHARGE'.
-- 10 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HM_BILL_CHARGE carries a verified HUB_CLAIM key
-- (CLAIM_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_bill_charge'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BILL_CHARGE_ID'
      - 'BILL_AMT'
      - 'TARIFF_EXCESS_DED'
      - 'CHARGE_ID'
      - 'BILL_AMT_BREAKUP1'
      - 'DISALLOW_REASON'
      - 'DISALLOW_AMT'
      - 'APPROVED_AMT'
      - 'BILL_AMT_BREAKUP2'
      - 'TARIFF_DED_TOTAL'
derived_columns:
  PARENT_BK: 'claim_id'
  PARENT_NK: "'HUB_CLAIM|' || (claim_id)"
  BILL_CHARGE_ID: 'bill_charge_id'
  BILL_AMT: 'bill_amt'
  TARIFF_EXCESS_DED: 'tariff_excess_ded'
  CHARGE_ID: 'charge_id'
  BILL_AMT_BREAKUP1: 'bill_amt_breakup1'
  DISALLOW_REASON: 'disallow_reason'
  DISALLOW_AMT: 'disallow_amt'
  APPROVED_AMT: 'approved_amt'
  BILL_AMT_BREAKUP2: 'bill_amt_breakup2'
  TARIFF_DED_TOTAL: 'tariff_ded_total'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_BILL_CHARGE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
