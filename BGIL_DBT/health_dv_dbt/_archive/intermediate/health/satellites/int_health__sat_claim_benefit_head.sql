-- Intermediate harmonisation view for SAT_CLAIM_BENEFIT_HEAD (HUB_CLAIM grain).
-- Stitched via a single source table, plus a UNION-appended fallback for 2 table(s) that lack the full multi-active child key.
-- record_source lists every table that actually contributed to a given row.
select * from (

select parent_bk, benefit_head_code_ck, claimed_amount, record_source from (
    select distinct
        case_id as parent_bk,
        cast(null as varchar) as benefit_head_code_ck,
        nullif(trim(to_varchar(total)), '') as claimed_amount,
        'BJAZ_HAT_OCR_FINA_DTLS_LST' as record_source
    from {{ ref('stg_health__bjaz_hat_ocr_fina_dtls_lst') }}
    where case_id is not null
    )

union all

select parent_bk, benefit_head_code_ck, claimed_amount, record_source from (
    select distinct
        clid as parent_bk,
        cast(null as varchar) as benefit_head_code_ck,
        nullif(trim(to_varchar(claimed_amt)), '') as claimed_amount,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where clid is not null
    )

)
