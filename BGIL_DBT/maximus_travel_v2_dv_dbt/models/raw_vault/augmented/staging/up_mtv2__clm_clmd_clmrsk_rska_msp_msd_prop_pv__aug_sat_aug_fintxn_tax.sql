{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_FINTXN_TAX from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- 2 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(payment_id),'')) is not null then 'PAY:' || nullif(trim(payment_id), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'TDS' as TAX_TYPE,
        cast(null as varchar) as INVOICE_MODE,
        cast(null as varchar) as SUPPLIER_INVOICE_NUMBER,
        tds_certificate as TDS_CERTIFICATE_NUMBER,
        tds_dd_payable_at as TDS_DEMAND_DRAFT_PAYABLE_AT,
        tds_dd_state as TDS_DEMAND_DRAFT_STATE,
        tds_nondeduction_flag as TDS_NON_DEDUCTION_INDICATOR,
        tds_nondeduction_reason as TDS_NON_DEDUCTION_REASON,
        tds_mode_of_payment as TDS_REMITTANCE_MODE,
        tds_portal_payment_reference_number as TDS_REMITTANCE_PORTAL_REFERENCE_NUMBER,
        tds_separate_cheque_flag as TDS_SEPARATE_CHEQUE_INDICATOR,
        tds_separate_payment_flag as TDS_SEPARATE_PAYMENT_INDICATOR,
        tds_maximus_reference_no as TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
        tds_waived_flag as TDS_WAIVED_INDICATOR,
        tds_waived_reason as TDS_WAIVED_REASON,
        cast(null as varchar) as UGST_AMOUNT,
        cast(null as varchar) as UGST_RATE,
        cast(null as varchar) as UTGST_AMOUNT,
        cast(null as varchar) as VAT_REGISTRATION_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where tds_certificate is not null or tds_dd_payable_at is not null or tds_dd_state is not null or tds_maximus_reference_no is not null or tds_mode_of_payment is not null or tds_nondeduction_flag is not null or tds_nondeduction_reason is not null or tds_portal_payment_reference_number is not null or tds_separate_cheque_flag is not null or tds_separate_payment_flag is not null or tds_waived_flag is not null or tds_waived_reason is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(invoice_number),'')) is not null then 'INV:' || nullif(trim(invoice_number), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE,
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
        ugst as UGST_AMOUNT,
        ugst_percentage as UGST_RATE,
        cast(null as varchar) as UTGST_AMOUNT,
        cast(null as varchar) as VAT_REGISTRATION_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where ugst is not null or ugst_percentage is not null
