{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_PARTY_FRAUD_PROFILE (HUB_PARTY grain).
-- Attribute-level merge across 2 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_party_fraud_profile.sql stage() model.

select parent_bk, fraud_category, fraud_suspicion_indicator, negative_list_reason, record_source
from (
    with t0 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(fraud_type)), '') as fraud_category,
            nullif(trim(to_varchar(suspfraud)), '') as fraud_suspicion_indicator
        from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by fraud_category, fraud_suspicion_indicator) = 1
    ),
         t1 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(suspfraud)), '') as fraud_suspicion_indicator,
            nullif(trim(to_varchar(blacklistreason)), '') as negative_list_reason
        from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by fraud_suspicion_indicator, negative_list_reason) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t0.fraud_category) as fraud_category,
        coalesce(t0.fraud_suspicion_indicator, t1.fraud_suspicion_indicator) as fraud_suspicion_indicator,
        coalesce(t1.negative_list_reason) as negative_list_reason,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_HM_HOSP_MASTER_EXTN1' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
