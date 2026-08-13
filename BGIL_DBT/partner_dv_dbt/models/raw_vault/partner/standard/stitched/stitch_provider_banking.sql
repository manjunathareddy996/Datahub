{{ config(
    materialized='incremental',
    unique_key='parent_bk',
    incremental_strategy='merge'
) }}

-- PARTNER STANDARD-MODEL stitch for SAT_PROVIDER_BANKING (HUB_PARTY grain).
-- 2 table(s) contributing at this grain.
--
-- INCREMENTAL PROCESSING STANDARD:
--   1. CTEs are singular -- one source table each, no joins, dedupped to the
--      HUB_PARTY grain. No incremental predicate inside them.
--   2. Final query only joins the same-grain CTEs.
--   3. The incremental predicate is applied ONCE at the end as an OR across both
--      tables' load_date. A key is reprocessed if EITHER source changed, and
--      because the filter sits AFTER the join the surviving row still carries
--      attributes from both tables (no blanking).
--   4. load_date is MAX() OVER (PARTITION BY <key>) -- the row_number() dedup
--      below orders by attribute value, not by time, so the surviving row's own
--      timestamp is not necessarily the latest for that key.
--
-- WINDOW -- derived entirely from what is already loaded. No arguments:
--   INCREMENTAL RUN (table exists): process only rows whose source change date
--     is newer than MAX(src_load_date) already held here.
--   FULL LOAD (first run, or --full-refresh): is_incremental() is false, the
--     predicate disappears, everything is processed.
--   src_load_date is persisted purely to serve as that high-water mark.
--
--   Just: dbt run --select stitch_provider_banking
--
-- Both sources carry GG_CHANGE_DATE, so there is no blind spot here.
-- Note the two grains key off different columns (PARTNER_ID vs HOSID); each
-- CTE partitions load_date by its own key.

select
    parent_bk,
    gstregistrationnumber,
    tcsstatus,
    record_source,
    src_load_date
from (
    with t0 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(tcs_status)), '') as tcsstatus,
            max(gg_change_date) over (partition by partner_id) as load_date
        from {{ ref('stg_partner__bjaz_clm_supp_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by tcsstatus) = 1
    ),
         t1 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(stax_reg_no)), '') as gstregistrationnumber,
            max(gg_change_date) over (partition by hosid) as load_date
        from {{ ref('stg_partner__bjaz_hm_hospital_master') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by gstregistrationnumber) = 1
    ),
         joined as (
        select
            coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
            t1.gstregistrationnumber as gstregistrationnumber,
            t0.tcsstatus as tcsstatus,
            array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_CLM_SUPP_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER' end), ', ') as record_source,
            t0.load_date as t0_load_date,
            t1.load_date as t1_load_date,
            greatest(
                coalesce(t0.load_date, '1900-01-01'::timestamp_ntz),
                coalesce(t1.load_date, '1900-01-01'::timestamp_ntz)
            ) as src_load_date
        from t0
        full outer join t1 on t0.parent_bk = t1.parent_bk
    )

    select *
    from joined
    {% if is_incremental() %}
    -- Only rows newer than what is already loaded. is_incremental() is false on
    -- the first run and on --full-refresh, so those load everything.
    -- COALESCE guards the table-exists-but-empty case: a bare MAX() would return
    -- NULL there, every comparison would be NULL, and nothing would load.
    where t0_load_date > (select coalesce(max(src_load_date), '1900-01-01'::timestamp_ntz) from {{ this }})
       or t1_load_date > (select coalesce(max(src_load_date), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
)
