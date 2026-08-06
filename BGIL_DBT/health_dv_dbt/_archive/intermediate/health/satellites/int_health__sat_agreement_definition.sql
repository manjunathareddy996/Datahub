-- Intermediate harmonisation view for SAT_AGREEMENT_DEFINITION (HUB_AGREEMENT grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 4 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, agreement_category, agreement_name, agreement_status, agreement_type, effective_date, execution_date, expiry_date, record_source
from (
    with t0 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(effective_date)), '') as effective_date,
            nullif(trim(to_varchar(empanel_date)), '') as execution_date
        from {{ ref('stg_health__bjaz_hm_hospital_master') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by effective_date, execution_date) = 1
    ),
         t1 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(ppn_type)), '') as agreement_category,
            nullif(trim(to_varchar(type_of_mou)), '') as agreement_type,
            nullif(trim(to_varchar(mou_from_date)), '') as effective_date,
            nullif(trim(to_varchar(mou_revision_date)), '') as execution_date,
            nullif(trim(to_varchar(mou_to_date)), '') as expiry_date
        from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by agreement_category, agreement_type, effective_date, execution_date, expiry_date) = 1
    ),
         t2 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(hosnundernego)), '') as agreement_status,
            nullif(trim(to_varchar(trfvalfrom)), '') as effective_date,
            nullif(trim(to_varchar(trfvalto)), '') as expiry_date
        from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by agreement_status, effective_date, expiry_date) = 1
    ),
         t3 as (
        select distinct
            remedinet_provider_code as parent_bk,
            nullif(trim(to_varchar(tariff_name)), '') as agreement_name
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where remedinet_provider_code is not null
        qualify row_number() over (partition by parent_bk order by agreement_name) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t1.agreement_category) as agreement_category,
        coalesce(t3.agreement_name) as agreement_name,
        coalesce(t2.agreement_status) as agreement_status,
        coalesce(t1.agreement_type) as agreement_type,
        coalesce(t0.effective_date, t1.effective_date, t2.effective_date) as effective_date,
        coalesce(t0.execution_date, t1.execution_date) as execution_date,
        coalesce(t1.expiry_date, t2.expiry_date) as expiry_date,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER' end, case when t1.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER_EXTN' end, case when t2.parent_bk is not null then 'BJAZ_HM_HOSP_MASTER_EXTN1' end, case when t3.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )
