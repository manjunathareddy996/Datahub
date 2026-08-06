{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_POLICY_ENDORSEMENT (HUB_POLICY grain).
-- Attribute-level merge across 2 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_policy_endorsement.sql stage() model.

select parent_bk, endorsement_number_ck, effective_date, endorsement_date, endorsement_number, endorsement_type, record_source
from (
    with t0 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(endorsement_no)), '') as endorsement_number_ck,
            nullif(trim(to_varchar(endorsement_date)), '') as endorsement_date,
            nullif(trim(to_varchar(endorsement_no)), '') as endorsement_number
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where contract_id is not null and endorsement_no is not null
        qualify row_number() over (partition by parent_bk, endorsement_number_ck order by endorsement_date, endorsement_number) = 1
    ),
         t1 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(endt_no)), '') as endorsement_number_ck,
            nullif(trim(to_varchar(endt_eff_date)), '') as effective_date,
            nullif(trim(to_varchar(endtpass_on)), '') as endorsement_date,
            nullif(trim(to_varchar(endt_no)), '') as endorsement_number,
            nullif(trim(to_varchar(endt_type)), '') as endorsement_type
        from {{ ref('stg_health__bjaz_pmjay_prmbook_dtls') }}
        where policy_ref is not null and endt_no is not null
        qualify row_number() over (partition by parent_bk, endorsement_number_ck order by effective_date, endorsement_date, endorsement_number, endorsement_type) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t0.endorsement_number_ck, t1.endorsement_number_ck) as endorsement_number_ck,
        coalesce(t1.effective_date) as effective_date,
        coalesce(t0.endorsement_date, t1.endorsement_date) as endorsement_date,
        coalesce(t0.endorsement_number, t1.endorsement_number) as endorsement_number,
        coalesce(t1.endorsement_type) as endorsement_type,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_PMJAY_PRMBOOK_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk and t0.endorsement_number_ck = t1.endorsement_number_ck
    )
