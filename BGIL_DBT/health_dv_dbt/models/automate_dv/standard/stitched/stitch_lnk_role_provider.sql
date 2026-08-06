{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_LNK_ROLE_PROVIDER (HUB_PARTY grain).
-- Attribute-level merge across 6 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_lnk_role_provider.sql stage() model.

select parent_bk, role_type_ck, empanelment_date, nurse_to_patient_ratio, preferred_provider_indicator, provider_code, provider_type, suspension_indicator, record_source
from (
    select parent_bk, 'PROVIDER' as role_type_ck, empanelment_date, nurse_to_patient_ratio, preferred_provider_indicator, provider_code, provider_type, suspension_indicator, record_source
    from (
    with t0 as (
        select distinct
            hospital_id as parent_bk,
            nullif(trim(to_varchar(hospital_type)), '') as provider_type
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where hospital_id is not null
        qualify row_number() over (partition by parent_bk order by provider_type) = 1
    ),
         t1 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(preferred_flag)), '') as preferred_provider_indicator
        from {{ ref('stg_health__bjaz_hm_hospital_master') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by preferred_provider_indicator) = 1
    ),
         t2 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(year_empanelment)), '') as empanelment_date
        from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by empanelment_date) = 1
    ),
         t3 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(ntopratio)), '') as nurse_to_patient_ratio,
            nullif(trim(to_varchar(suspendforext)), '') as suspension_indicator
        from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by nurse_to_patient_ratio, suspension_indicator) = 1
    ),
         t4 as (
        select distinct
            payer_code as parent_bk,
            nullif(trim(to_varchar(remedinet_provider_code)), '') as provider_code
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where payer_code is not null
        qualify row_number() over (partition by parent_bk order by provider_code) = 1
    ),
         t5 as (
        select distinct
            customer_id as parent_bk,
            nullif(trim(to_varchar(hospital_code)), '') as provider_code
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where customer_id is not null
        qualify row_number() over (partition by parent_bk order by provider_code) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk) as parent_bk,
        coalesce(t2.empanelment_date) as empanelment_date,
        coalesce(t3.nurse_to_patient_ratio) as nurse_to_patient_ratio,
        coalesce(t1.preferred_provider_indicator) as preferred_provider_indicator,
        coalesce(t4.provider_code, t5.provider_code) as provider_code,
        coalesce(t0.provider_type) as provider_type,
        coalesce(t3.suspension_indicator) as suspension_indicator,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t1.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER' end, case when t2.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER_EXTN' end, case when t3.parent_bk is not null then 'BJAZ_HM_HOSP_MASTER_EXTN1' end, case when t4.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end, case when t5.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    )
)
