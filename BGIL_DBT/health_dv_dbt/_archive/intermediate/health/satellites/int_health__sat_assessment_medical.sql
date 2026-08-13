-- Intermediate harmonisation view for SAT_ASSESSMENT_MEDICAL (HUB_ASSESSMENT grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 4 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, abnormality_indicator, medical_management_date, medical_management_type, medical_test_type, recommended_exclusion, record_source
from (
    with t0 as (
        select distinct
            scrutiny_no as parent_bk,
            nullif(trim(to_varchar(test_code)), '') as medical_test_type
        from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
        where scrutiny_no is not null
        qualify row_number() over (partition by parent_bk order by medical_test_type) = 1
    ),
         t1 as (
        select distinct
            docasess_id as parent_bk,
            nullif(trim(to_varchar(medical_mgmt_date)), '') as medical_management_date,
            nullif(trim(to_varchar(medical_mgmt_type)), '') as medical_management_type
        from {{ ref('stg_health__bjaz_hm_doctor_assess') }}
        where docasess_id is not null
        qualify row_number() over (partition by parent_bk order by medical_management_date, medical_management_type) = 1
    ),
         t2 as (
        select distinct
            docasess_id as parent_bk,
            nullif(trim(to_varchar(medical_mgmt_date)), '') as medical_management_date,
            nullif(trim(to_varchar(medical_mgmt_type)), '') as medical_management_type
        from {{ ref('stg_health__bjaz_hm_doctor_multi_assess') }}
        where docasess_id is not null
        qualify row_number() over (partition by parent_bk order by medical_management_date, medical_management_type) = 1
    ),
         t3 as (
        select distinct
            docasess_id as parent_bk,
            nullif(trim(to_varchar(medical_mgmt_date)), '') as medical_management_date,
            nullif(trim(to_varchar(medical_mgmt_type)), '') as medical_management_type
        from {{ ref('stg_health__bjaz_hm_pcs_multi_assess') }}
        where docasess_id is not null
        qualify row_number() over (partition by parent_bk order by medical_management_date, medical_management_type) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        cast(null as varchar) as abnormality_indicator,
        coalesce(t1.medical_management_date, t2.medical_management_date, t3.medical_management_date) as medical_management_date,
        coalesce(t1.medical_management_type, t2.medical_management_type, t3.medical_management_type) as medical_management_type,
        coalesce(t0.medical_test_type) as medical_test_type,
        cast(null as varchar) as recommended_exclusion,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PP_MEM_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_HM_DOCTOR_ASSESS' end, case when t2.parent_bk is not null then 'BJAZ_HM_DOCTOR_MULTI_ASSESS' end, case when t3.parent_bk is not null then 'BJAZ_HM_PCS_MULTI_ASSESS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )
