{{ config(
    materialized='incremental',
    unique_key='parent_bk',
    incremental_strategy='merge'
) }}

-- PARTNER STANDARD-MODEL stitch for SAT_PARTY_HEALTH_PROFILE (HUB_PARTY grain).
-- 4 table(s) contributing at this grain.
--
-- INCREMENTAL PROCESSING STANDARD:
--   1. CTEs are singular -- one source table each, no joins, dedupped to the
--      HUB_PARTY grain. No incremental predicate inside them.
--   2. Final query only joins the same-grain CTEs.
--   3. The incremental predicate is applied ONCE at the end, as an OR across
--      every contributing table's load_date. A key is reprocessed if ANY source
--      changed in the window, and because the filter sits AFTER the join the
--      surviving row still carries attributes from all 4 tables.
--   4. load_date per CTE is MAX() OVER (PARTITION BY parent_bk) -- these CTEs
--      dedup with row_number() ordered by attribute values, not by time, so the
--      surviving row's own timestamp is not necessarily the latest one.
--
-- Window is passed as arguments:
--   dbt run --select stitch_party_health_profile \
--     --vars '{"incr_start_ts": "2026-02-17", "incr_end_ts": "2026-02-21"}'
--   Unset = full range, so a plain run processes everything.
--
-- BJAZ_SH_MEM_DTLS_EXTN (t2) and BJAZ_SPP_MEMBER_DTLS (t3) have no
-- GG_CHANGE_DATE. They contribute attributes normally but cannot signal a
-- change, so their keys are always included -- otherwise a change made only in
-- those tables is missed silently.

select
    parent_bk,
    bodymassindex,
    height,
    maternitystatus,
    smokerindicator,
    weight,
    record_source
from (
    with t0 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(height_cm)), '') as height,
            nullif(trim(to_varchar(pregnant_yn)), '') as maternitystatus,
            nullif(trim(to_varchar(smoker_yn)), '') as smokerindicator,
            nullif(trim(to_varchar(weight_kg)), '') as weight,
            max(gg_change_date) over (partition by partner_id) as load_date
        from {{ ref('stg_partner__bjaz_ec_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by height, maternitystatus, smokerindicator, weight) = 1
    ),
         t1 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(obesity_flag)), '') as bodymassindex,
            nullif(trim(to_varchar(height_flag)), '') as height,
            nullif(trim(to_varchar(smoker_flag)), '') as smokerindicator,
            nullif(trim(to_varchar(weight_flag)), '') as weight,
            max(gg_change_date) over (partition by partner_id) as load_date
        from {{ ref('stg_partner__bjaz_hcf_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by bodymassindex, height, smokerindicator, weight) = 1
    ),
         t2 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(smoker_yn)), '') as smokerindicator
        from {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by smokerindicator) = 1
    ),
         t3 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(obesity)), '') as bodymassindex,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_partner__bjaz_spp_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by bodymassindex, weight) = 1
    ),
         joined as (
        select
            coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
            coalesce(t1.bodymassindex, t3.bodymassindex) as bodymassindex,
            coalesce(t0.height, t1.height) as height,
            t0.maternitystatus as maternitystatus,
            coalesce(t0.smokerindicator, t1.smokerindicator, t2.smokerindicator) as smokerindicator,
            coalesce(t0.weight, t1.weight, t3.weight) as weight,
            array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t3.parent_bk is not null then 'BJAZ_SPP_MEMBER_DTLS' end), ', ') as record_source,
            t0.load_date as t0_load_date,
            t1.load_date as t1_load_date,
            t2.parent_bk as t2_key,
            t3.parent_bk as t3_key
        from t0
        full outer join t1 on t0.parent_bk = t1.parent_bk
        full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
        full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )

    select *
    from joined
    {% if is_incremental() %}
    where (t0_load_date >= '{{ var("incr_start_ts", "1900-01-01") }}'::timestamp_ntz
           and t0_load_date < '{{ var("incr_end_ts", "9999-12-31") }}'::timestamp_ntz)
       or (t1_load_date >= '{{ var("incr_start_ts", "1900-01-01") }}'::timestamp_ntz
           and t1_load_date < '{{ var("incr_end_ts", "9999-12-31") }}'::timestamp_ntz)
       or t2_key is not null
       or t3_key is not null
    {% endif %}
)
