{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_CLAIM_PROVIDER_BILLING from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 23 payload column(s); the child key is BILL_NUMBER.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF_CLAIM_PROVIDER_BILLING:
    is_hashdiff: true
    columns:
      - 'ADMISSIBLE_AMOUNT_IN_INR'
      - 'APPLICABLE_TERM_END_DATE'
      - 'APPLICABLE_TERM_START_DATE'
      - 'ASSISTANCE_COMPANY_REPRICING_DISCOUNT_AMOUNT'
      - 'BALANCE_SUM_INSURED_AMOUNT'
      - 'BILLED_AMOUNT_IN_BILL_CURRENCY'
      - 'BILL_AMOUNT_BREAKUP'
      - 'BILL_CURRENCY_CODE'
      - 'BILL_DISCOUNT_AMOUNT'
      - 'BILL_LINE_PARTICULARS'
      - 'BILL_NUMBER'
      - 'BILL_PAYABLE_REASON'
      - 'DEDUCTION_AMOUNT_IN_SUM_INSURED_CURRENCY'
      - 'DISALLOWANCE_BREAKUP'
      - 'EXCHANGE_RATE_APPLICABLE_DATE'
      - 'EXCHANGE_RATE_TO_INR'
      - 'EXCHANGE_RATE_TO_POLICY_SUM_INSURED_CURRENCY'
      - 'FINAL_ADMISSIBLE_AMOUNT_IN_BILL_CURRENCY'
      - 'FINAL_ADMISSIBLE_AMOUNT_IN_POLICY_SUM_INSURED_CURRENCY'
      - 'NON_ADMISSIBLE_AMOUNT'
      - 'NON_ADMISSIBLE_REMARKS'
      - 'PROVIDER_FACILITY_NAME'
      - 'REVIEWED_AMOUNT'
      - 'REVIEW_DESCRIPTION'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  BILL_NUMBER: "coalesce(nullif(trim(bill_no), ''),'')"
  ADMISSIBLE_AMOUNT_IN_INR: 'actual_admissible_amount_in_inr'
  APPLICABLE_TERM_END_DATE: 'term_end_date'
  APPLICABLE_TERM_START_DATE: 'term_start_date'
  ASSISTANCE_COMPANY_REPRICING_DISCOUNT_AMOUNT: 'aga_discount_repricing'
  BALANCE_SUM_INSURED_AMOUNT: 'bsi'
  BILLED_AMOUNT_IN_BILL_CURRENCY: 'actual_bill_amount'
  BILL_AMOUNT_BREAKUP: 'bill_breakup'
  BILL_CURRENCY_CODE: 'actual_bill_currency'
  BILL_DISCOUNT_AMOUNT: 'discount'
  BILL_LINE_PARTICULARS: 'particular'
  BILL_PAYABLE_REASON: 'bill_payable_reason'
  DEDUCTION_AMOUNT_IN_SUM_INSURED_CURRENCY: 'deduction_in_si_currency'
  DISALLOWANCE_BREAKUP: 'disallowed_breakup'
  EXCHANGE_RATE_APPLICABLE_DATE: 'applicable_date_of_conversion'
  EXCHANGE_RATE_TO_INR: 'conversion_rate_in_inr'
  EXCHANGE_RATE_TO_POLICY_SUM_INSURED_CURRENCY: 'conversion_rate_to_policy_si_currency'
  FINAL_ADMISSIBLE_AMOUNT_IN_BILL_CURRENCY: 'final_admissible_amount_in_bill_currency'
  FINAL_ADMISSIBLE_AMOUNT_IN_POLICY_SUM_INSURED_CURRENCY: 'final_admissible_amount_in_policy_si_currency'
  NON_ADMISSIBLE_AMOUNT: 'non_admissible_amount'
  NON_ADMISSIBLE_REMARKS: 'non_admissible_remarks'
  PROVIDER_FACILITY_NAME: 'facility_name'
  REVIEWED_AMOUNT: 'reviewed_value'
  REVIEW_DESCRIPTION: 'review_description'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
