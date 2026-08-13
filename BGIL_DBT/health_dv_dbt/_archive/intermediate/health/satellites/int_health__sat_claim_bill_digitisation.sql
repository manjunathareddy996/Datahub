-- Intermediate harmonisation view for SAT_CLAIM_BILL_DIGITISATION (HUB_CLAIM grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 3 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, bill_reference, invoice_status, record_source
from (
    with t0 as (
        select distinct
            case_id as parent_bk,
            nullif(trim(to_varchar(inward_no)), '') as bill_reference
        from {{ ref('stg_health__bjaz_hat_ocr_bill_details') }}
        where case_id is not null
        qualify row_number() over (partition by parent_bk order by bill_reference) = 1
    ),
         t1 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(ocr_bill_no)), '') as bill_reference,
            nullif(trim(to_varchar(bill_status)), '') as invoice_status
        from {{ ref('stg_health__bjaz_hm_bill_detail') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by bill_reference, invoice_status) = 1
    ),
         t2 as (
        select distinct
            claim_id as parent_bk,
            nullif(trim(to_varchar(ocr_bill_no)), '') as bill_reference,
            nullif(trim(to_varchar(bill_status)), '') as invoice_status
        from {{ ref('stg_health__bjaz_hm_bill_detail_ocr') }}
        where claim_id is not null
        qualify row_number() over (partition by parent_bk order by bill_reference, invoice_status) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk) as parent_bk,
        coalesce(t0.bill_reference, t1.bill_reference, t2.bill_reference) as bill_reference,
        coalesce(t1.invoice_status, t2.invoice_status) as invoice_status,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HAT_OCR_BILL_DETAILS' end, case when t1.parent_bk is not null then 'BJAZ_HM_BILL_DETAIL' end, case when t2.parent_bk is not null then 'BJAZ_HM_BILL_DETAIL_OCR' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    )
