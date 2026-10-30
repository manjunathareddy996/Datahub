{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_FINTXN_TAX from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
-- 3 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when nullif(trim(w1_claimpaymentid),'') is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'GST' as TAX_TYPE,
        invoice_mode as INVOICE_MODE,
        invoice_no as SUPPLIER_INVOICE_NUMBER,
        cast(null as varchar) as TDS_CERTIFICATE_NUMBER,
        cast(null as varchar) as TDS_DEMAND_DRAFT_PAYABLE_AT,
        cast(null as varchar) as TDS_DEMAND_DRAFT_STATE,
        cast(null as varchar) as TDS_NON_DEDUCTION_INDICATOR,
        cast(null as varchar) as TDS_NON_DEDUCTION_REASON,
        cast(null as varchar) as TDS_REMITTANCE_MODE,
        cast(null as varchar) as TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER,
        cast(null as varchar) as TDS_SEPARATE_CHEQUE_INDICATOR,
        cast(null as varchar) as TDS_SEPARATE_PAYMENT_INDICATOR,
        cast(null as varchar) as TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
        cast(null as varchar) as TDS_WAIVED_INDICATOR,
        cast(null as varchar) as TDS_WAIVED_REASON,
        cast(null as varchar) as UGST_AMOUNT,
        cast(null as varchar) as UGST_RATE,
        cast(null as varchar) as UTGST_AMOUNT,
        cast(null as varchar) as VAT_REGISTRATION_NUMBER,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmpay_payp_pv') }}
    where invoice_mode is not null or invoice_no is not null
union all
    select
        nullif(trim(case when nullif(trim(w1_claimpaymentid),'') is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'UGST' as TAX_TYPE,
        cast(null as varchar) as INVOICE_MODE,
        cast(null as varchar) as SUPPLIER_INVOICE_NUMBER,
        cast(null as varchar) as TDS_CERTIFICATE_NUMBER,
        cast(null as varchar) as TDS_DEMAND_DRAFT_PAYABLE_AT,
        cast(null as varchar) as TDS_DEMAND_DRAFT_STATE,
        cast(null as varchar) as TDS_NON_DEDUCTION_INDICATOR,
        cast(null as varchar) as TDS_NON_DEDUCTION_REASON,
        cast(null as varchar) as TDS_REMITTANCE_MODE,
        cast(null as varchar) as TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER,
        cast(null as varchar) as TDS_SEPARATE_CHEQUE_INDICATOR,
        cast(null as varchar) as TDS_SEPARATE_PAYMENT_INDICATOR,
        cast(null as varchar) as TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
        cast(null as varchar) as TDS_WAIVED_INDICATOR,
        cast(null as varchar) as TDS_WAIVED_REASON,
        cast(null as varchar) as UGST_AMOUNT,
        cast(null as varchar) as UGST_RATE,
        ugst_amount as UTGST_AMOUNT,
        cast(null as varchar) as VAT_REGISTRATION_NUMBER,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmpay_payp_pv') }}
    where ugst_amount is not null
union all
    select
        nullif(trim(case when nullif(trim(w1_claimpaymentid),'') is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'VAT' as TAX_TYPE,
        cast(null as varchar) as INVOICE_MODE,
        cast(null as varchar) as SUPPLIER_INVOICE_NUMBER,
        cast(null as varchar) as TDS_CERTIFICATE_NUMBER,
        cast(null as varchar) as TDS_DEMAND_DRAFT_PAYABLE_AT,
        cast(null as varchar) as TDS_DEMAND_DRAFT_STATE,
        cast(null as varchar) as TDS_NON_DEDUCTION_INDICATOR,
        cast(null as varchar) as TDS_NON_DEDUCTION_REASON,
        cast(null as varchar) as TDS_REMITTANCE_MODE,
        cast(null as varchar) as TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER,
        cast(null as varchar) as TDS_SEPARATE_CHEQUE_INDICATOR,
        cast(null as varchar) as TDS_SEPARATE_PAYMENT_INDICATOR,
        cast(null as varchar) as TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
        cast(null as varchar) as TDS_WAIVED_INDICATOR,
        cast(null as varchar) as TDS_WAIVED_REASON,
        cast(null as varchar) as UGST_AMOUNT,
        cast(null as varchar) as UGST_RATE,
        cast(null as varchar) as UTGST_AMOUNT,
        vat_number as VAT_REGISTRATION_NUMBER,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmpay_payp_pv') }}
    where vat_number is not null
