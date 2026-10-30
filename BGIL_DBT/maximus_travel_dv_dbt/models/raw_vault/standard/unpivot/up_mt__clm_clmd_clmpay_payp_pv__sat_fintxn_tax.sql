{{ config(materialized='view') }}

-- UNPIVOT for SAT_FINTXN_TAX from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
-- one row PER INSTANCE: 4 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by TAX_TYPE.
-- The hash is taken once, downstream, by stg2_mt_up__clm_clmd_clmpay_payp_pv__sat_fintxn_tax.
--
-- Payload is null-padded to the SATELLITE's full payload (13 column(s)), not to this
-- feeder's columns, so every feeder of SAT_FINTXN_TAX is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   gst                                      7 attribute(s)
--   tds                                      1 attribute(s)
--   tds_on_interest                          1 attribute(s)
--   vat                                      1 attribute(s)

    select
        nullif(trim(case when nullif(trim(w1_claimpaymentid),'') is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'GST' as TAX_TYPE,
        cgst_amount as CGST_AMOUNT,
        cast(null as varchar) as CGST_RATE,
        igst_amount as IGST_AMOUNT,
        cast(null as varchar) as IGST_RATE,
        payment_state as PLACE_OF_SUPPLY,
        sgst_amount as SGST_AMOUNT,
        cast(null as varchar) as SGST_RATE,
        cast(null as varchar) as TAX_APPLICABLE_INDICATOR,
        tax_invoice_date as TAX_INVOICE_DATE,
        tax_invoice_number as TAX_INVOICE_NUMBER,
        gst_percentage as TAX_RATE,
        cast(null as varchar) as TDS_AMOUNT,
        cast(null as varchar) as TDS_RATE,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmpay_payp_pv') }}
    where cgst_amount is not null or gst_percentage is not null or igst_amount is not null or payment_state is not null or sgst_amount is not null or tax_invoice_date is not null or tax_invoice_number is not null
union all
    select
        nullif(trim(case when nullif(trim(w1_claimpaymentid),'') is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'TDS' as TAX_TYPE,
        cast(null as varchar) as CGST_AMOUNT,
        cast(null as varchar) as CGST_RATE,
        cast(null as varchar) as IGST_AMOUNT,
        cast(null as varchar) as IGST_RATE,
        cast(null as varchar) as PLACE_OF_SUPPLY,
        cast(null as varchar) as SGST_AMOUNT,
        cast(null as varchar) as SGST_RATE,
        cast(null as varchar) as TAX_APPLICABLE_INDICATOR,
        cast(null as varchar) as TAX_INVOICE_DATE,
        cast(null as varchar) as TAX_INVOICE_NUMBER,
        cast(null as varchar) as TAX_RATE,
        tds_amount as TDS_AMOUNT,
        cast(null as varchar) as TDS_RATE,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmpay_payp_pv') }}
    where tds_amount is not null
union all
    select
        nullif(trim(case when nullif(trim(w1_claimpaymentid),'') is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'TDS_ON_INTEREST' as TAX_TYPE,
        cast(null as varchar) as CGST_AMOUNT,
        cast(null as varchar) as CGST_RATE,
        cast(null as varchar) as IGST_AMOUNT,
        cast(null as varchar) as IGST_RATE,
        cast(null as varchar) as PLACE_OF_SUPPLY,
        cast(null as varchar) as SGST_AMOUNT,
        cast(null as varchar) as SGST_RATE,
        cast(null as varchar) as TAX_APPLICABLE_INDICATOR,
        cast(null as varchar) as TAX_INVOICE_DATE,
        cast(null as varchar) as TAX_INVOICE_NUMBER,
        cast(null as varchar) as TAX_RATE,
        tds_on_interest as TDS_AMOUNT,
        cast(null as varchar) as TDS_RATE,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmpay_payp_pv') }}
    where tds_on_interest is not null
union all
    select
        nullif(trim(case when nullif(trim(w1_claimpaymentid),'') is not null then 'PAY:' || nullif(trim(w1_claimpaymentid), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'VAT' as TAX_TYPE,
        cast(null as varchar) as CGST_AMOUNT,
        cast(null as varchar) as CGST_RATE,
        cast(null as varchar) as IGST_AMOUNT,
        cast(null as varchar) as IGST_RATE,
        cast(null as varchar) as PLACE_OF_SUPPLY,
        cast(null as varchar) as SGST_AMOUNT,
        cast(null as varchar) as SGST_RATE,
        vat_applicable as TAX_APPLICABLE_INDICATOR,
        cast(null as varchar) as TAX_INVOICE_DATE,
        cast(null as varchar) as TAX_INVOICE_NUMBER,
        cast(null as varchar) as TAX_RATE,
        cast(null as varchar) as TDS_AMOUNT,
        cast(null as varchar) as TDS_RATE,
        rec_refresh_at,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmpay_payp_pv') }}
    where vat_applicable is not null
