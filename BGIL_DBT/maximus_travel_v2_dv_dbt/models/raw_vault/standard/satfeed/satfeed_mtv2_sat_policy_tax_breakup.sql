{{ config(materialized='view') }}

-- FEED for SAT_POLICY_TAX_BREAKUP (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 10 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_TAX_BREAKUP to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        CESS_AMOUNT as CESS_AMOUNT,
        CGST_AMOUNT as CGST_AMOUNT,
        IGST_AMOUNT as IGST_AMOUNT,
        SGST_AMOUNT as SGST_AMOUNT,
        STAMP_DUTY_AMOUNT as STAMP_DUTY_AMOUNT,
        GST_BIFURCATION as GST_BIFURCATION,
        GST_TDS_AMOUNT as GST_TDS_AMOUNT,
        GST_TYPE as GST_TYPE,
        STAMP_DUTY_RECEIPT_NUMBER as STAMP_DUTY_RECEIPT_NUMBER,
        TOTAL_TAX_AMOUNT as TOTAL_TAX_AMOUNT,
        HASHDIFF_POLICY_TAX_BREAKUP as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        CESS_AMOUNT as CESS_AMOUNT,
        CGST_AMOUNT as CGST_AMOUNT,
        IGST_AMOUNT as IGST_AMOUNT,
        SGST_AMOUNT as SGST_AMOUNT,
        STAMP_DUTY_AMOUNT as STAMP_DUTY_AMOUNT,
        GST_BIFURCATION as GST_BIFURCATION,
        GST_TDS_AMOUNT as GST_TDS_AMOUNT,
        GST_TYPE as GST_TYPE,
        STAMP_DUTY_RECEIPT_NUMBER as STAMP_DUTY_RECEIPT_NUMBER,
        TOTAL_TAX_AMOUNT as TOTAL_TAX_AMOUNT,
        HASHDIFF_POLICY_TAX_BREAKUP as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where POLICY_HKEY is not null
