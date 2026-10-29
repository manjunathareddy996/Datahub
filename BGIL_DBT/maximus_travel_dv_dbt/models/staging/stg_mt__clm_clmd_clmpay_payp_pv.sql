{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
--
-- This view CARRIES MAP ROWS; it is a start view for the key and payload layers.
--
-- Typing: flattened JSON shreds and pivoted EAV views with no source type list, so every
-- value is cast to a trimmed VARCHAR. An absent EAV label on this feed is the EMPTY
-- STRING, not NULL, which is why each value is nullif(trim(...),'') here and why every
-- key is guarded again in mt_keyrules.render_key().
--
-- Every source identifier is DOUBLE-QUOTED (directive D-QUOTE): seven column names in
-- this feed begin with a digit and do not compile unquoted. Their aliases carry a col_
-- prefix for the same reason -- an alias may not begin with a digit either.
--
-- Shred lineage carried through deliberately (FOREIGN_KEY, KEY_HASH, PARENT_KEY_HASH, PARENT_RECORD_HASH): it appears in no row of the map and
-- the whole sub-document key layer is built on it.

with source as (

    select
    "FOREIGN_KEY" as foreign_key,
    "PARENT_RECORD_HASH" as parent_record_hash,
    "PARENT_KEY_HASH" as parent_key_hash,
    "KEY_HASH" as key_hash,
    try_to_timestamp_ntz(trim(to_varchar("INC_JOB_CREATED_AT"))) as inc_job_created_at,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("ACCOUNT_CATEGORY_CODE")), '') as account_category_code,
    nullif(trim(to_varchar("ACCOUNT_NUMBER")), '') as account_number,
    nullif(trim(to_varchar("ACCOUNT_TYPE")), '') as account_type,
    nullif(trim(to_varchar("AOL_MODE")), '') as aol_mode,
    nullif(trim(to_varchar("BANK_NAME")), '') as bank_name,
    nullif(trim(to_varchar("BRANCH_CODE")), '') as branch_code,
    nullif(trim(to_varchar("CASHLESS_CLAIM_TYPE")), '') as cashless_claim_type,
    nullif(trim(to_varchar("CGST_AMOUNT")), '') as cgst_amount,
    nullif(trim(to_varchar("CHEQUE_DATE")), '') as cheque_date,
    nullif(trim(to_varchar("CHEQUE_NUMBER")), '') as cheque_number,
    nullif(trim(to_varchar("CLAIM_PAYMENT_STATUS")), '') as claim_payment_status,
    nullif(trim(to_varchar("CLAIM_PAYMENT_VOUCHER")), '') as claim_payment_voucher,
    nullif(trim(to_varchar("ELECTRIC_TO_SOLAR")), '') as electric_to_solar,
    nullif(trim(to_varchar("FINAL_RESERVE")), '') as final_reserve,
    nullif(trim(to_varchar("GST_PERCENTAGE")), '') as gst_percentage,
    nullif(trim(to_varchar("IGST_AMOUNT")), '') as igst_amount,
    nullif(trim(to_varchar("INITIAL_RESERVE")), '') as initial_reserve,
    nullif(trim(to_varchar("INTEREST_AMOUNT")), '') as interest_amount,
    nullif(trim(to_varchar("INVOICE_MODE")), '') as invoice_mode,
    nullif(trim(to_varchar("INVOICE_NO")), '') as invoice_no,
    nullif(trim(to_varchar("NEFT_APPROVAL")), '') as neft_approval,
    nullif(trim(to_varchar("PAYABLE_AT")), '') as payable_at,
    nullif(trim(to_varchar("PAYMENT_AUTHORIZATION_DATE")), '') as payment_authorization_date,
    nullif(trim(to_varchar("PAYMENT_MODE")), '') as payment_mode,
    nullif(trim(to_varchar("PAYMENT_STATE")), '') as payment_state,
    nullif(trim(to_varchar("PAYMENT_TRANSACTION_TYPE")), '') as payment_transaction_type,
    nullif(trim(to_varchar("PAYMENT_TYPE")), '') as payment_type,
    nullif(trim(to_varchar("PRINT_LOCATION_CODE")), '') as print_location_code,
    nullif(trim(to_varchar("REFERENCE_BILL_NO")), '') as reference_bill_no,
    nullif(trim(to_varchar("REFERENCE_ID")), '') as reference_id,
    nullif(trim(to_varchar("REFERENCE_TYPE")), '') as reference_type,
    nullif(trim(to_varchar("SECTION")), '') as section,
    nullif(trim(to_varchar("SGST_AMOUNT")), '') as sgst_amount,
    nullif(trim(to_varchar("TAX_INVOICE_DATE")), '') as tax_invoice_date,
    nullif(trim(to_varchar("TAX_INVOICE_NUMBER")), '') as tax_invoice_number,
    nullif(trim(to_varchar("TDS_AMOUNT")), '') as tds_amount,
    nullif(trim(to_varchar("TDS_ON_INTEREST")), '') as tds_on_interest,
    nullif(trim(to_varchar("TOTAL_AMOUNT_INCLUDING_TAXTRANSACTION_CURRENCY")), '') as total_amount_including_taxtransaction_currency,
    nullif(trim(to_varchar("TRANSACTIONID")), '') as transactionid,
    nullif(trim(to_varchar("TYPE_OF_DAMAGE")), '') as type_of_damage,
    nullif(trim(to_varchar("UGST_AMOUNT")), '') as ugst_amount,
    nullif(trim(to_varchar("UTR_DATE")), '') as utr_date,
    nullif(trim(to_varchar("UTR_NO")), '') as utr_no,
    nullif(trim(to_varchar("VAT_APPLICABLE")), '') as vat_applicable,
    nullif(trim(to_varchar("VAT_NUMBER")), '') as vat_number
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW') }}

)

select * from source
