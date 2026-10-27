{{ config(materialized='view') }}

-- UNPIVOT for SAT_FINTXN_TAX from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 2 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by TAX_TYPE.
-- The hash is taken once, downstream, by stg2_mtv2_up__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_fintxn_tax.
--
-- Payload is null-padded to the SATELLITE's full payload (13 column(s)), not to this
-- feeder's columns, so every feeder of SAT_FINTXN_TAX is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   gst                                      9 attribute(s)
--   tds                                      3 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(invoice_number),'')) is not null then 'INV:' || nullif(trim(invoice_number), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE,
        'GST' as TAX_TYPE,
        cgst as CGST_AMOUNT,
        cgst_percentage as CGST_RATE,
        igst as IGST_AMOUNT,
        igst_percentage as IGST_RATE,
        cast(null as varchar) as PLACE_OF_SUPPLY,
        sgst as SGST_AMOUNT,
        sgst_percentage as SGST_RATE,
        gst_applicability as TAX_APPLICABLE_INDICATOR,
        cast(null as varchar) as TAX_INVOICE_DATE,
        invoice_number as TAX_INVOICE_NUMBER,
        total_gst_percentage as TAX_RATE,
        cast(null as varchar) as TDS_AMOUNT,
        cast(null as varchar) as TDS_RATE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where cgst is not null or cgst_percentage is not null or gst_applicability is not null or igst is not null or igst_percentage is not null or invoice_number is not null or sgst is not null or sgst_percentage is not null or total_gst_percentage is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(payment_id),'')) is not null then 'PAY:' || nullif(trim(payment_id), '') end),'') as FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT,
        'TDS' as TAX_TYPE,
        cast(null as varchar) as CGST_AMOUNT,
        cast(null as varchar) as CGST_RATE,
        cast(null as varchar) as IGST_AMOUNT,
        cast(null as varchar) as IGST_RATE,
        cast(null as varchar) as PLACE_OF_SUPPLY,
        cast(null as varchar) as SGST_AMOUNT,
        cast(null as varchar) as SGST_RATE,
        coalesce(tds_applicability, tds_applicable_flag) as TAX_APPLICABLE_INDICATOR,
        cast(null as varchar) as TAX_INVOICE_DATE,
        cast(null as varchar) as TAX_INVOICE_NUMBER,
        cast(null as varchar) as TAX_RATE,
        tds_amount as TDS_AMOUNT,
        tds_rate as TDS_RATE,
        'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where tds_amount is not null or tds_applicability is not null or tds_applicable_flag is not null or tds_rate is not null
