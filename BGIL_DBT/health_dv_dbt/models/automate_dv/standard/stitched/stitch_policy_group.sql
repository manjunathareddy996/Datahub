{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_POLICY_GROUP (HUB_POLICY grain).
-- Attribute-level merge across 4 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_policy_group.sql stage() model.

select parent_bk, contributory_indicator, employer_contribution_percentage, floater_indicator, group_size, group_type, master_policy_number, member_count, record_source
from (
    with t0 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(floater_or_not)), '') as floater_indicator
        from {{ ref('stg_health__bjaz_card_dtls') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by floater_indicator) = 1
    ),
         t1 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(comp_contr)), '') as contributory_indicator,
            nullif(trim(to_varchar(comp_cntrper)), '') as employer_contribution_percentage
        from {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by contributory_indicator, employer_contribution_percentage) = 1
    ),
         t2 as (
        select distinct
            reg_no as parent_bk,
            nullif(trim(to_varchar(member_emp_header)), '') as group_size,
            nullif(trim(to_varchar(empr_emp_relation)), '') as group_type,
            nullif(trim(to_varchar(total_no_proposed)), '') as member_count
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where reg_no is not null
        qualify row_number() over (partition by parent_bk order by group_size, group_type, member_count) = 1
    ),
         t3 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(ctny_master_contract_id)), '') as master_policy_number
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by master_policy_number) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t1.contributory_indicator) as contributory_indicator,
        coalesce(t1.employer_contribution_percentage) as employer_contribution_percentage,
        coalesce(t0.floater_indicator) as floater_indicator,
        coalesce(t2.group_size) as group_size,
        coalesce(t2.group_type) as group_type,
        coalesce(t3.master_policy_number) as master_policy_number,
        coalesce(t2.member_count) as member_count,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_CARD_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_ECARD_POL_DTLS_CONFIG' end, case when t2.parent_bk is not null then 'BJAZ_GRP_HLT_DTLS' end, case when t3.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )
