-- Intermediate harmonisation view for SAT_PARTY_GROUP_HOUSEHOLD (HUB_PARTY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 4 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, member_count, relationship_composition, record_source
from (
    with t0 as (
        select distinct
            user_id as parent_bk,
            nullif(trim(to_varchar(total_member_nos)), '') as member_count,
            nullif(trim(to_varchar(member_combo)), '') as relationship_composition
        from {{ ref('stg_health__ba_hcp_dt_premium') }}
        where user_id is not null
        qualify row_number() over (partition by parent_bk order by member_count, relationship_composition) = 1
    ),
         t1 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_family_mem_combination)), '') as relationship_composition
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_composition) = 1
    ),
         t2 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_family_mem_combination)), '') as relationship_composition
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by relationship_composition) = 1
    ),
         t3 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(total_mem_cnt)), '') as member_count
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by member_count) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t0.member_count, t3.member_count) as member_count,
        coalesce(t0.relationship_composition, t1.relationship_composition, t2.relationship_composition) as relationship_composition,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_DT_PREMIUM' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t2.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t3.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )
