{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_EXPENSE_LINE from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 12 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_EXPENSE_LINE:
    is_hashdiff: true
    columns:
      - 'EXPENSE_AMOUNT'
      - 'EXPENSE_FEE_HEAD_CODE'
      - 'EXPENSE_FEE_HEAD_DESCRIPTION'
      - 'EXPENSE_PAYMENT_AMOUNT'
      - 'EXPENSE_PAYMENT_APPROVER_REFERENCE'
      - 'EXPENSE_PAYMENT_DATE'
      - 'EXPENSE_PAYMENT_MODE'
      - 'EXPENSE_PAYMENT_NARRATION'
      - 'EXPENSE_PAYMENT_PORTAL_REFERENCE_NUMBER'
      - 'EXPENSE_PAYMENT_REFERENCE_NUMBER'
      - 'EXPENSE_PAYMENT_TYPE'
      - 'EXPENSE_TYPE'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  EXPENSE_AMOUNT: 'coalesce(amount_of_expense, expense_amount)'
  EXPENSE_FEE_HEAD_CODE: 'expense_fee_head_code'
  EXPENSE_FEE_HEAD_DESCRIPTION: 'expense_fee_heads'
  EXPENSE_PAYMENT_AMOUNT: 'expense_payment_amount'
  EXPENSE_PAYMENT_APPROVER_REFERENCE: 'expense_payment_approved_by'
  EXPENSE_PAYMENT_DATE: 'expense_payment_date'
  EXPENSE_PAYMENT_MODE: 'mode_of_expense_payment'
  EXPENSE_PAYMENT_NARRATION: 'expense_reference_text'
  EXPENSE_PAYMENT_PORTAL_REFERENCE_NUMBER: 'expense_portal_payment_reference_number'
  EXPENSE_PAYMENT_REFERENCE_NUMBER: 'expense_payment_reference_no'
  EXPENSE_PAYMENT_TYPE: 'expense_payment_type'
  EXPENSE_TYPE: 'type_of_expenses'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
