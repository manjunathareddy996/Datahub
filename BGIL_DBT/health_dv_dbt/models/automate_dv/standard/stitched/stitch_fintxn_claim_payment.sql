{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_FINTXN_CLAIM_PAYMENT (HUB_FINANCIAL_TRANSACTION grain).
-- Attribute-level merge across 2 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_fintxn_claim_payment.sql stage() model.

select parent_bk, cheque_date, cheque_dispatch_date, cheque_received_date, net_paid_amount, payment_date, payment_mode, payment_status, tds_on_claim_amount, utr_number, record_source
from (
    with t0 as (
        select distinct
            claim_no || '|' || utr_no as parent_bk,
            nullif(trim(to_varchar(cheque_date)), '') as cheque_date,
            nullif(trim(to_varchar(cheque_dis_date)), '') as cheque_dispatch_date,
            nullif(trim(to_varchar(cheque_rec_date)), '') as cheque_received_date,
            nullif(trim(to_varchar(payable_to_hospital)), '') as net_paid_amount,
            nullif(trim(to_varchar(mode_of_payment)), '') as payment_mode,
            nullif(trim(to_varchar(pay_status)), '') as payment_status,
            nullif(trim(to_varchar(tds_amount)), '') as tds_on_claim_amount,
            nullif(trim(to_varchar(utr_no)), '') as utr_number
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where claim_no is not null and utr_no is not null
        qualify row_number() over (partition by parent_bk order by cheque_date, cheque_dispatch_date, cheque_received_date, net_paid_amount, payment_mode, payment_status, tds_on_claim_amount, utr_number) = 1
    ),
         t1 as (
        select distinct
            tpa_trans_key as parent_bk,
            nullif(trim(to_varchar(cheque_date)), '') as cheque_date,
            nullif(trim(to_varchar(net_payble_amt)), '') as net_paid_amount,
            nullif(trim(to_varchar(payment_date)), '') as payment_date,
            nullif(trim(to_varchar(tds_amount)), '') as tds_on_claim_amount
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where tpa_trans_key is not null
        qualify row_number() over (partition by parent_bk order by cheque_date, net_paid_amount, payment_date, tds_on_claim_amount) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t0.cheque_date, t1.cheque_date) as cheque_date,
        coalesce(t0.cheque_dispatch_date) as cheque_dispatch_date,
        coalesce(t0.cheque_received_date) as cheque_received_date,
        coalesce(t0.net_paid_amount, t1.net_paid_amount) as net_paid_amount,
        coalesce(t1.payment_date) as payment_date,
        coalesce(t0.payment_mode) as payment_mode,
        coalesce(t0.payment_status) as payment_status,
        coalesce(t0.tds_on_claim_amount, t1.tds_on_claim_amount) as tds_on_claim_amount,
        coalesce(t0.utr_number) as utr_number,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t1.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
