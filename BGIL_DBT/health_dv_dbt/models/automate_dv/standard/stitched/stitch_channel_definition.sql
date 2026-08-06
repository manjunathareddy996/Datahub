{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_CHANNEL_DEFINITION (HUB_DISTRIBUTION_CHANNEL grain).
-- Attribute-level merge across 8 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_channel_definition.sql stage() model.

select parent_bk, channel_category, channel_name, channel_type, sub_channel_code, record_source
from (
    with t0 as (
        select distinct
            pd_partner_id as parent_bk,
            nullif(trim(to_varchar(pd_partner_type)), '') as channel_type,
            nullif(trim(to_varchar(pd_sub_imd_code)), '') as sub_channel_code
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pd_partner_id is not null
        qualify row_number() over (partition by parent_bk order by channel_type, sub_channel_code) = 1
    ),
         t1 as (
        select distinct
            pd_partner_id as parent_bk,
            nullif(trim(to_varchar(pd_partner_type)), '') as channel_type,
            nullif(trim(to_varchar(pd_sub_imd_code)), '') as sub_channel_code
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_partner_id is not null
        qualify row_number() over (partition by parent_bk order by channel_type, sub_channel_code) = 1
    ),
         t2 as (
        select distinct
            pd_partner_id as parent_bk,
            nullif(trim(to_varchar(pd_partner_type)), '') as channel_type,
            nullif(trim(to_varchar(pd_sub_imd_code)), '') as sub_channel_code
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_partner_id is not null
        qualify row_number() over (partition by parent_bk order by channel_type, sub_channel_code) = 1
    ),
         t3 as (
        select distinct
            pd_partner_id as parent_bk,
            nullif(trim(to_varchar(pd_partner_type)), '') as channel_type,
            nullif(trim(to_varchar(pd_sub_imd_code)), '') as sub_channel_code
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_partner_id is not null
        qualify row_number() over (partition by parent_bk order by channel_type, sub_channel_code) = 1
    ),
         t4 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(issuance_source)), '') as channel_category,
            nullif(trim(to_varchar(lg_name)), '') as channel_name,
            nullif(trim(to_varchar(partner_type)), '') as channel_type
        from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by channel_category, channel_name, channel_type) = 1
    ),
         t5 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(partner_type)), '') as channel_type
        from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by channel_type) = 1
    ),
         t6 as (
        select distinct
            imd_code as parent_bk,
            nullif(trim(to_varchar(source_name)), '') as channel_name
        from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
        where imd_code is not null
        qualify row_number() over (partition by parent_bk order by channel_name) = 1
    ),
         t7 as (
        select distinct
            imd_code as parent_bk,
            nullif(trim(to_varchar(source_name)), '') as channel_name
        from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
        where imd_code is not null
        qualify row_number() over (partition by parent_bk order by channel_name) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk) as parent_bk,
        coalesce(t4.channel_category) as channel_category,
        coalesce(t4.channel_name, t6.channel_name, t7.channel_name) as channel_name,
        coalesce(t0.channel_type, t1.channel_type, t2.channel_type, t3.channel_type, t4.channel_type, t5.channel_type) as channel_type,
        coalesce(t0.sub_channel_code, t1.sub_channel_code, t2.sub_channel_code, t3.sub_channel_code) as sub_channel_code,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t2.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t3.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t4.parent_bk is not null then 'BJAZ_BANDHAN_MEDI_CLAM' end, case when t5.parent_bk is not null then 'BJAZ_EHH_POL_DTLS' end, case when t6.parent_bk is not null then 'BJAZ_GP_HOSPITAL_CASH' end, case when t7.parent_bk is not null then 'BJAZ_HDFC_SEC_FHPP' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    )
