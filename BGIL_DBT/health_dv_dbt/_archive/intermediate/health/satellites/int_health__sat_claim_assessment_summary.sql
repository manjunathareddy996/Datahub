-- Intermediate harmonisation view for SAT_CLAIM_ASSESSMENT_SUMMARY (HUB_CLAIM grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 2 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, admissible_loss_amount, assessment_date, deductible_applied, total_deduction_amount, record_source
from (
    with t0 as (
        select distinct
            claim_no as parent_bk,
            nullif(trim(to_varchar(total_allowed_amount)), '') as admissible_loss_amount,
            nullif(trim(to_varchar(deduction_amount)), '') as total_deduction_amount
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where claim_no is not null
        qualify row_number() over (partition by parent_bk order by admissible_loss_amount, total_deduction_amount) = 1
    ),
         t1 as (
        select distinct
            bjaz_claim_id as parent_bk,
            nullif(trim(to_varchar(recommend_amount)), '') as admissible_loss_amount,
            nullif(trim(to_varchar(recommend_on)), '') as assessment_date,
            nullif(trim(to_varchar(compulsary_deduction)), '') as deductible_applied,
            nullif(trim(to_varchar(deducted_amount)), '') as total_deduction_amount
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where bjaz_claim_id is not null
        qualify row_number() over (partition by parent_bk order by admissible_loss_amount, assessment_date, deductible_applied, total_deduction_amount) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t0.admissible_loss_amount, t1.admissible_loss_amount) as admissible_loss_amount,
        coalesce(t1.assessment_date) as assessment_date,
        coalesce(t1.deductible_applied) as deductible_applied,
        coalesce(t0.total_deduction_amount, t1.total_deduction_amount) as total_deduction_amount,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end, case when t1.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
