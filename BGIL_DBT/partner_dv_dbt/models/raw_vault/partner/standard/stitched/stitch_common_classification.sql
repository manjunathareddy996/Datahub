{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_COMMON_CLASSIFICATION (HUB_PARTY grain).
-- 5 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, prioritycode, segmentcode, record_source
from (
    with t0 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(vip_cust)), '') as prioritycode,
            nullif(trim(to_varchar(ucic_flag)), '') as segmentcode
        from {{ ref('stg_partner__azbj_partner_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by prioritycode, segmentcode) = 1
    ),
         t1 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(vip_cust)), '') as prioritycode
        from {{ ref('stg_partner__bjaz_azbj_part_ext_hist') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by prioritycode) = 1
    ),
         t2 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(vip_flg)), '') as prioritycode
        from {{ ref('stg_partner__bjaz_hm_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by prioritycode) = 1
    ),
         t3 as (
        select distinct
            intermediary_id as parent_bk,
            nullif(trim(to_varchar(flagging)), '') as segmentcode
        from {{ ref('stg_partner__bjaz_intermediary') }}
        where intermediary_id is not null
        qualify row_number() over (partition by parent_bk order by segmentcode) = 1
    ),
         t4 as (
        select distinct
            intermediary_id as parent_bk,
            nullif(trim(to_varchar(flagging)), '') as segmentcode
        from {{ ref('stg_partner__bjaz_intermediary_hist') }}
        where intermediary_id is not null
        qualify row_number() over (partition by parent_bk order by segmentcode) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk) as parent_bk,
        coalesce(t0.prioritycode, t1.prioritycode, t2.prioritycode) as prioritycode,
        coalesce(t0.segmentcode, t3.segmentcode, t4.segmentcode) as segmentcode,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'AZBJ_PARTNER_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_AZBJ_PART_EXT_HIST' end, case when t2.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t3.parent_bk is not null then 'BJAZ_INTERMEDIARY' end, case when t4.parent_bk is not null then 'BJAZ_INTERMEDIARY_HIST' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    )
