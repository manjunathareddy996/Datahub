{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PROVIDER_BANKING (HUB_PARTY grain).
-- 2 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, gstregistrationnumber, tcsstatus, record_source
from (
    with t0 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(tcs_status)), '') as tcsstatus
        from {{ ref('stg_partner__bjaz_clm_supp_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by tcsstatus) = 1
    ),
         t1 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(stax_reg_no)), '') as gstregistrationnumber
        from {{ ref('stg_partner__bjaz_hm_hospital_master') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by gstregistrationnumber) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk) as parent_bk,
        t1.gstregistrationnumber as gstregistrationnumber,
        t0.tcsstatus as tcsstatus,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_CLM_SUPP_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    )
