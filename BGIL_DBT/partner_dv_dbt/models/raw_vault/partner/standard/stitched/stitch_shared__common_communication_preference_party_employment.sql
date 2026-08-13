{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_COMMON_COMMUNICATION_PREFERENCE, SAT_PARTY_EMPLOYMENT (HUB_PARTY grain).
-- 2 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, correspondencelanguage, marketingoptinindicator, employmentstatus, record_source
from (
    with t0 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(language)), '') as correspondencelanguage,
            nullif(trim(to_varchar(literature)), '') as marketingoptinindicator
        from {{ ref('stg_partner__bjaz_cp_part_hist') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by correspondencelanguage, marketingoptinindicator) = 1
    ),
         t1 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(language)), '') as correspondencelanguage,
            nullif(trim(to_varchar(literature)), '') as marketingoptinindicator
        from {{ ref('stg_partner__cp_partners') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by correspondencelanguage, marketingoptinindicator) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t0.correspondencelanguage, t1.correspondencelanguage) as correspondencelanguage,
        coalesce(t0.marketingoptinindicator, t1.marketingoptinindicator) as marketingoptinindicator,
        cast(null as varchar) as employmentstatus,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_CP_PART_HIST' end, case when t1.parent_bk is not null then 'CP_PARTNERS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
