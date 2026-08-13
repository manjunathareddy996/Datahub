-- Intermediate harmonisation view for SAT_CLAIM_PROVIDER_BILLING (HUB_CLAIM grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 4 table(s), plus a UNION-appended fallback for 1 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, bill_number_ck, approved_amount, authorised_amount, bill_date, bill_number, bill_status_type, bill_type, billed_amount, disallowance_reason, disallowed_amount, record_source from (
    with t0 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(bill_id)), '') as bill_number_ck,
            nullif(trim(to_varchar(bill_id)), '') as bill_number
        from {{ ref('stg_health__bjaz_hm_bill_charge') }}
        where claim_id is not null and bill_id is not null
        qualify row_number() over (partition by parent_bk, bill_number_ck order by bill_number) = 1
    ),
         t1 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(bill_id)), '') as bill_number_ck,
            nullif(trim(to_varchar(tot_approved_amt)), '') as approved_amount,
            nullif(trim(to_varchar(bill_date)), '') as bill_date,
            nullif(trim(to_varchar(bill_id)), '') as bill_number,
            nullif(trim(to_varchar(bill_status_type)), '') as bill_status_type,
            nullif(trim(to_varchar(bill_type)), '') as bill_type,
            nullif(trim(to_varchar(tot_bill_amt)), '') as billed_amount,
            nullif(trim(to_varchar(dis_app_reason)), '') as disallowance_reason,
            nullif(trim(to_varchar(tot_disallow_amt)), '') as disallowed_amount
        from {{ ref('stg_health__bjaz_hm_bill_detail') }}
        where claim_id is not null and bill_id is not null
        qualify row_number() over (partition by parent_bk, bill_number_ck order by approved_amount, bill_date, bill_number, bill_status_type, bill_type, billed_amount, disallowance_reason, disallowed_amount) = 1
    ),
         t2 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(bill_id)), '') as bill_number_ck,
            nullif(trim(to_varchar(tot_approved_amt)), '') as approved_amount,
            nullif(trim(to_varchar(tot_app_amtmou)), '') as authorised_amount,
            nullif(trim(to_varchar(bill_date)), '') as bill_date,
            nullif(trim(to_varchar(hos_bill_no)), '') as bill_number,
            nullif(trim(to_varchar(bill_status_type)), '') as bill_status_type,
            nullif(trim(to_varchar(bill_type)), '') as bill_type,
            nullif(trim(to_varchar(tot_bill_amt)), '') as billed_amount,
            nullif(trim(to_varchar(dis_app_reason)), '') as disallowance_reason,
            nullif(trim(to_varchar(tot_disallow_amt)), '') as disallowed_amount
        from {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
        where claim_id is not null and bill_id is not null
        qualify row_number() over (partition by parent_bk, bill_number_ck order by approved_amount, authorised_amount, bill_date, bill_number, bill_status_type, bill_type, billed_amount, disallowance_reason, disallowed_amount) = 1
    ),
         t3 as (
        select distinct
            clid as parent_bk,
            nullif(trim(to_varchar(hospital_bill_no)), '') as bill_number_ck,
            nullif(trim(to_varchar(hospital_bill_no)), '') as bill_number
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where clid is not null and hospital_bill_no is not null
        qualify row_number() over (partition by parent_bk, bill_number_ck order by bill_number) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t0.bill_number_ck, t1.bill_number_ck, t2.bill_number_ck, t3.bill_number_ck) as bill_number_ck,
        coalesce(t1.approved_amount, t2.approved_amount) as approved_amount,
        coalesce(t2.authorised_amount) as authorised_amount,
        coalesce(t1.bill_date, t2.bill_date) as bill_date,
        coalesce(t0.bill_number, t1.bill_number, t2.bill_number, t3.bill_number) as bill_number,
        coalesce(t1.bill_status_type, t2.bill_status_type) as bill_status_type,
        coalesce(t1.bill_type, t2.bill_type) as bill_type,
        coalesce(t1.billed_amount, t2.billed_amount) as billed_amount,
        coalesce(t1.disallowance_reason, t2.disallowance_reason) as disallowance_reason,
        coalesce(t1.disallowed_amount, t2.disallowed_amount) as disallowed_amount,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_BILL_CHARGE' end, case when t1.parent_bk is not null then 'BJAZ_HM_BILL_DETAIL' end, case when t2.parent_bk is not null then 'BJAZ_HM_BILL_DETAIL_OCR' end, case when t3.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk and t0.bill_number_ck = t1.bill_number_ck
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk and coalesce(t0.bill_number_ck, t1.bill_number_ck) = t2.bill_number_ck
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk and coalesce(coalesce(t0.bill_number_ck, t1.bill_number_ck), t2.bill_number_ck) = t3.bill_number_ck
    )

union all

select parent_bk, bill_number_ck, approved_amount, authorised_amount, bill_date, bill_number, bill_status_type, bill_type, billed_amount, disallowance_reason, disallowed_amount, record_source from (
    select distinct
        claim_id as parent_bk,
        cast(null as varchar) as bill_number_ck,
        nullif(trim(to_varchar(tot_approved_amt)), '') as approved_amount,
        cast(null as varchar) as authorised_amount,
        cast(null as varchar) as bill_date,
        cast(null as varchar) as bill_number,
        cast(null as varchar) as bill_status_type,
        cast(null as varchar) as bill_type,
        cast(null as varchar) as billed_amount,
        cast(null as varchar) as disallowance_reason,
        nullif(trim(to_varchar(tot_disallow_amt)), '') as disallowed_amount,
        'BJAZ_HM_PRO_ASSESSMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
    where claim_id is not null
    )

)
