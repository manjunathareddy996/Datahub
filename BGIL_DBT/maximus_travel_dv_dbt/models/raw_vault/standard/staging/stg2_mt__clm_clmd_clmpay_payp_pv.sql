{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
-- Covers this view's 3 key slot(s) and its 7 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   CLAIM_HKEY                         HUB_CLAIM  (12 row(s) in the map)
--   FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT HUB_FINANCIAL_TRANSACTION / claim-payment  (27 row(s) in the map)
--   PAYMENT_INSTRUMENT_HKEY__PAYEE_BANK_ACCOUNT HUB_PAYMENT_INSTRUMENT / payee-bank-account  (5 row(s) in the map)
--   HASHDIFF_CLAIM_PAYMENT_TRANCHE     SAT_CLAIM_PAYMENT_TRANCHE payload 3 of 10 live here
--   HASHDIFF_CLAIM_PROVIDER_BILLING    SAT_CLAIM_PROVIDER_BILLING payload 0 of 5 live here
--   HASHDIFF_CLAIM_RESERVE             SAT_CLAIM_RESERVE payload 2 of 5 live here
--   HASHDIFF_FINTXN_ACCOUNTING         SAT_FINTXN_ACCOUNTING payload 1 of 1 live here
--   HASHDIFF_FINTXN_CLAIM_PAYMENT      SAT_FINTXN_CLAIM_PAYMENT payload 8 of 8 live here
--   HASHDIFF_FINTXN_HEADER             SAT_FINTXN_HEADER payload 4 of 7 live here
--   HASHDIFF_INSTRUMENT_DEFINITION     SAT_INSTRUMENT_DEFINITION payload 4 of 5 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__clm_clmd_clmpay_payp_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT: 'FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT'
  PAYMENT_INSTRUMENT_HKEY__PAYEE_BANK_ACCOUNT: 'PAYMENT_INSTRUMENT_NK__PAYEE_BANK_ACCOUNT'
  HASHDIFF_CLAIM_PAYMENT_TRANCHE:
    is_hashdiff: true
    columns:
      - 'APPROVAL_REFERENCE'
      - 'FINAL_INDICATOR'
      - 'GROSS_AMOUNT'
      - 'HOLD_INDICATOR'
      - 'HOLD_REASON'
      - 'NET_AMOUNT'
      - 'PAYMENT_DATE__SAT_CLAIM_PAYMENT_TRANCHE'
      - 'PAYMENT_MODE__SAT_CLAIM_PAYMENT_TRANCHE'
      - 'PAYMENT_TYPE'
      - 'STATUS'
      - 'TRANCHE_NUMBER'
  HASHDIFF_CLAIM_PROVIDER_BILLING:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'BILLED_AMOUNT'
      - 'BILL_NUMBER'
      - 'BILL_STATUS_TYPE'
      - 'DISALLOWANCE_REASON'
      - 'DISALLOWED_AMOUNT'
  HASHDIFF_CLAIM_RESERVE:
    is_hashdiff: true
    columns:
      - 'CURRENT_RESERVE_AMOUNT'
      - 'INITIAL_RESERVE_AMOUNT'
      - 'OUTSTANDING_RESERVE_AMOUNT'
      - 'PAID_TO_DATE_AMOUNT'
      - 'RESERVE_HEAD'
      - 'RESERVE_TYPE'
  HASHDIFF_FINTXN_ACCOUNTING:
    is_hashdiff: true
    columns:
      - 'VOUCHER_NUMBER'
  HASHDIFF_FINTXN_CLAIM_PAYMENT:
    is_hashdiff: true
    columns:
      - 'CHEQUE_DATE'
      - 'CHEQUE_NUMBER'
      - 'INSTRUMENT_PAYABLE_AT_LOCATION'
      - 'INSTRUMENT_PRINT_LOCATION_CODE'
      - 'NEFT_APPROVAL_REFERENCE'
      - 'PAYMENT_DATE'
      - 'PAYMENT_MODE'
      - 'UTR_NUMBER'
  HASHDIFF_FINTXN_HEADER:
    is_hashdiff: true
    columns:
      - 'ORG_UNIT_CODE'
      - 'SOURCE_REFERENCE_NUMBER'
      - 'SOURCE_REFERENCE_TYPE'
      - 'TRANSACTION_CHANNEL'
      - 'TRANSACTION_DATE'
      - 'TRANSACTION_NUMBER'
      - 'TRANSACTION_TYPE'
  HASHDIFF_INSTRUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_CATEGORY_CODE'
      - 'ACCOUNT_TYPE'
      - 'BANK_BRANCH_CODE'
      - 'BANK_NAME'
      - 'INSTRUMENT_STATUS'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT: "nullif(trim(case when coalesce(nullif(trim(w1_claimpaymentid),'')) is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'')"
  FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(w1_claimpaymentid),'')) is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),''))"
  PAYMENT_INSTRUMENT_BK__PAYEE_BANK_ACCOUNT: "nullif(trim(case when coalesce(nullif(trim(account_number),'')) is not null then 'ACCT:' || nullif(trim(account_number), '') end),'')"
  PAYMENT_INSTRUMENT_NK__PAYEE_BANK_ACCOUNT: "'HUB_PAYMENT_INSTRUMENT|' || (nullif(trim(case when coalesce(nullif(trim(account_number),'')) is not null then 'ACCT:' || nullif(trim(account_number), '') end),''))"
  ACCOUNT_TYPE: 'account_type'
  APPROVAL_REFERENCE: 'cast(null as varchar)'
  APPROVED_AMOUNT: 'cast(null as varchar)'
  BANK_NAME: 'bank_name'
  BILLED_AMOUNT: 'cast(null as varchar)'
  BILL_NUMBER: "coalesce(nullif(trim(reference_bill_no), ''),'')"
  BILL_STATUS_TYPE: 'cast(null as varchar)'
  CHEQUE_DATE: 'cheque_date'
  CHEQUE_NUMBER: 'cheque_number'
  CURRENT_RESERVE_AMOUNT: 'final_reserve'
  DISALLOWANCE_REASON: 'cast(null as varchar)'
  DISALLOWED_AMOUNT: 'cast(null as varchar)'
  FINAL_INDICATOR: 'cast(null as varchar)'
  GROSS_AMOUNT: 'total_amount_including_taxtransaction_currency'
  HOLD_INDICATOR: 'cast(null as varchar)'
  HOLD_REASON: 'cast(null as varchar)'
  INITIAL_RESERVE_AMOUNT: 'initial_reserve'
  INSTRUMENT_STATUS: 'cast(null as varchar)'
  NET_AMOUNT: 'cast(null as varchar)'
  ORG_UNIT_CODE: 'cast(null as varchar)'
  OUTSTANDING_RESERVE_AMOUNT: 'cast(null as varchar)'
  PAID_TO_DATE_AMOUNT: 'cast(null as varchar)'
  PAYMENT_DATE: 'utr_date'
  PAYMENT_DATE__SAT_CLAIM_PAYMENT_TRANCHE: 'cast(null as varchar)'
  PAYMENT_MODE: 'payment_mode'
  PAYMENT_MODE__SAT_CLAIM_PAYMENT_TRANCHE: 'cast(null as varchar)'
  PAYMENT_TYPE: 'payment_type'
  RESERVE_HEAD: "coalesce(nullif(trim(w2_payreservetypre), ''),'')"
  RESERVE_TYPE: 'cast(null as varchar)'
  SOURCE_REFERENCE_NUMBER: 'reference_id'
  SOURCE_REFERENCE_TYPE: 'reference_type'
  STATUS: 'claim_payment_status'
  TRANCHE_NUMBER: "coalesce(nullif(trim(w1_claimpaymentid), ''),'')"
  TRANSACTION_CHANNEL: 'cast(null as varchar)'
  TRANSACTION_DATE: 'cast(null as varchar)'
  TRANSACTION_NUMBER: 'transactionid'
  TRANSACTION_TYPE: 'payment_transaction_type'
  UTR_NUMBER: 'utr_no'
  VOUCHER_NUMBER: 'claim_payment_voucher'
  INSTRUMENT_PAYABLE_AT_LOCATION: 'payable_at'
  INSTRUMENT_PRINT_LOCATION_CODE: 'print_location_code'
  NEFT_APPROVAL_REFERENCE: 'neft_approval'
  ACCOUNT_CATEGORY_CODE: 'account_category_code'
  BANK_BRANCH_CODE: 'branch_code'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
