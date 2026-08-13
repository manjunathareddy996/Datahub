{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_COMMON_ADMIN_GEOGRAPHY, SAT_COMMON_GEO (HUB_LOCATION grain).
-- 2 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, pincode, regioncode, regionname, subzonecode, zonecode, record_source
from (
    with t0 as (
        select distinct
            pincode as parent_bk,
            nullif(trim(to_varchar(pincode)), '') as pincode
        from {{ ref('stg_partner__bjaz_pincode') }}
        where pincode is not null
        qualify row_number() over (partition by parent_bk order by pincode) = 1
    ),
         t1 as (
        select distinct
            pincode as parent_bk,
            nullif(trim(to_varchar(pincode)), '') as pincode
        from {{ ref('stg_partner__bjaz_pincode_master') }}
        where pincode is not null
        qualify row_number() over (partition by parent_bk order by pincode) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        coalesce(t0.pincode, t1.pincode) as pincode,
        cast(null as varchar) as regioncode,
        cast(null as varchar) as regionname,
        cast(null as varchar) as subzonecode,
        cast(null as varchar) as zonecode,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_PINCODE' end, case when t1.parent_bk is not null then 'BJAZ_PINCODE_MASTER' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
