{{ config(materialized='view') }}

-- FEED for SAT_FINTXN_TAX (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 13 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_FINTXN_TAX to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_HKEY,
        TAX_TYPE as TAX_TYPE,
        CGST_AMOUNT as CGST_AMOUNT,
        CGST_RATE as CGST_RATE,
        IGST_AMOUNT as IGST_AMOUNT,
        IGST_RATE as IGST_RATE,
        PLACE_OF_SUPPLY as PLACE_OF_SUPPLY,
        SGST_AMOUNT as SGST_AMOUNT,
        SGST_RATE as SGST_RATE,
        TAX_APPLICABLE_INDICATOR as TAX_APPLICABLE_INDICATOR,
        TAX_INVOICE_DATE as TAX_INVOICE_DATE,
        TAX_INVOICE_NUMBER as TAX_INVOICE_NUMBER,
        TAX_RATE as TAX_RATE,
        TDS_AMOUNT as TDS_AMOUNT,
        TDS_RATE as TDS_RATE,
        HASHDIFF_FINTXN_TAX as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__clm_clmd_clmpay_payp_pv__sat_fintxn_tax') }}
    where FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__CLAIM_BILL_INVOICE as FINANCIAL_TRANSACTION_HKEY,
        TAX_TYPE as TAX_TYPE,
        CGST_AMOUNT as CGST_AMOUNT,
        CGST_RATE as CGST_RATE,
        IGST_AMOUNT as IGST_AMOUNT,
        IGST_RATE as IGST_RATE,
        PLACE_OF_SUPPLY as PLACE_OF_SUPPLY,
        SGST_AMOUNT as SGST_AMOUNT,
        SGST_RATE as SGST_RATE,
        TAX_APPLICABLE_INDICATOR as TAX_APPLICABLE_INDICATOR,
        TAX_INVOICE_DATE as TAX_INVOICE_DATE,
        TAX_INVOICE_NUMBER as TAX_INVOICE_NUMBER,
        TAX_RATE as TAX_RATE,
        TDS_AMOUNT as TDS_AMOUNT,
        TDS_RATE as TDS_RATE,
        HASHDIFF_FINTXN_TAX as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_fintxn_tax') }}
    where FINANCIAL_TRANSACTION_HKEY__CLAIM_BILL_INVOICE is not null
