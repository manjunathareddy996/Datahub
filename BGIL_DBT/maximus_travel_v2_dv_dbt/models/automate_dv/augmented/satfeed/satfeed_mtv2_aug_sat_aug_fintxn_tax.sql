{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_FINTXN_TAX: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_HKEY,
        TAX_TYPE,
        INVOICE_MODE,
        SUPPLIER_INVOICE_NUMBER,
        TDS_CERTIFICATE_NUMBER,
        TDS_DEMAND_DRAFT_PAYABLE_AT,
        TDS_DEMAND_DRAFT_STATE,
        TDS_NON_DEDUCTION_INDICATOR,
        TDS_NON_DEDUCTION_REASON,
        TDS_REMITTANCE_MODE,
        TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER,
        TDS_SEPARATE_CHEQUE_INDICATOR,
        TDS_SEPARATE_PAYMENT_INDICATOR,
        TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
        TDS_WAIVED_INDICATOR,
        TDS_WAIVED_REASON,
        UGST_AMOUNT,
        UGST_RATE,
        UTGST_AMOUNT,
        VAT_REGISTRATION_NUMBER,
        HASHDIFF_FINTXN_TAX as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmpay_payp_pv__sat_aug_fintxn_tax') }}
    where FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT as FINANCIAL_TRANSACTION_HKEY,
        TAX_TYPE,
        INVOICE_MODE,
        SUPPLIER_INVOICE_NUMBER,
        TDS_CERTIFICATE_NUMBER,
        TDS_DEMAND_DRAFT_PAYABLE_AT,
        TDS_DEMAND_DRAFT_STATE,
        TDS_NON_DEDUCTION_INDICATOR,
        TDS_NON_DEDUCTION_REASON,
        TDS_REMITTANCE_MODE,
        TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER,
        TDS_SEPARATE_CHEQUE_INDICATOR,
        TDS_SEPARATE_PAYMENT_INDICATOR,
        TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
        TDS_WAIVED_INDICATOR,
        TDS_WAIVED_REASON,
        UGST_AMOUNT,
        UGST_RATE,
        UTGST_AMOUNT,
        VAT_REGISTRATION_NUMBER,
        HASHDIFF_FINTXN_TAX as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_aug_fintxn_tax') }}
    where FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT is not null
