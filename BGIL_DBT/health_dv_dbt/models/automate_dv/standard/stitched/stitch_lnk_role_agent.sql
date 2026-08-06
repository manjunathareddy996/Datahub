{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_LNK_ROLE_AGENT (HUB_PARTY grain).
-- Attribute-level merge across 2 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_lnk_role_agent.sql stage() model.

select parent_bk, role_type_ck, agent_code, record_source
from (
    select parent_bk, 'AGENT' as role_type_ck, agent_code, record_source
    from (
    with t0 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(sub_agent_code)), '') as agent_code
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by agent_code) = 1
    ),
         t1 as (
        select distinct
            customer_id as parent_bk,
            nullif(trim(to_varchar(agent_code)), '') as agent_code
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where customer_id is not null
        qualify row_number() over (partition by parent_bk order by agent_code) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t0.agent_code, t1.agent_code) as agent_code,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end, case when t1.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
)
