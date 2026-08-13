{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_ORGANISATION_PROFILE (HUB_PARTY grain).
-- 5 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, annualturnover, dateofincorporation, groupname, industrydescription, legalconstitutiontype, msmeindicator, paidupcapital, parententityname, record_source
from (
    with t0 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(global_co_name)), '') as groupname,
            nullif(trim(to_varchar(industry)), '') as industrydescription,
            nullif(trim(to_varchar(msme_flag)), '') as msmeindicator,
            nullif(trim(to_varchar(paidup_capital)), '') as paidupcapital,
            nullif(trim(to_varchar(parent_co)), '') as parententityname
        from {{ ref('stg_partner__azbj_partner_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by groupname, industrydescription, msmeindicator, paidupcapital, parententityname) = 1
    ),
         t1 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(global_co_name)), '') as groupname,
            nullif(trim(to_varchar(industry)), '') as industrydescription,
            nullif(trim(to_varchar(paidup_capital)), '') as paidupcapital,
            nullif(trim(to_varchar(parent_co)), '') as parententityname
        from {{ ref('stg_partner__bjaz_azbj_part_ext_hist') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by groupname, industrydescription, paidupcapital, parententityname) = 1
    ),
         t2 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(ann_turnover)), '') as annualturnover,
            nullif(trim(to_varchar(establish_year)), '') as dateofincorporation,
            nullif(trim(to_varchar(msme_class)), '') as msmeindicator,
            nullif(trim(to_varchar(parent_co_name)), '') as parententityname
        from {{ ref('stg_partner__bjaz_clm_supp_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by annualturnover, dateofincorporation, msmeindicator, parententityname) = 1
    ),
         t3 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(legal_form)), '') as legalconstitutiontype
        from {{ ref('stg_partner__bjaz_cp_part_hist') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by legalconstitutiontype) = 1
    ),
         t4 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(legal_form)), '') as legalconstitutiontype
        from {{ ref('stg_partner__cp_partners') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by legalconstitutiontype) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk) as parent_bk,
        t2.annualturnover as annualturnover,
        t2.dateofincorporation as dateofincorporation,
        coalesce(t0.groupname, t1.groupname) as groupname,
        coalesce(t0.industrydescription, t1.industrydescription) as industrydescription,
        coalesce(t3.legalconstitutiontype, t4.legalconstitutiontype) as legalconstitutiontype,
        coalesce(t0.msmeindicator, t2.msmeindicator) as msmeindicator,
        coalesce(t0.paidupcapital, t1.paidupcapital) as paidupcapital,
        coalesce(t0.parententityname, t1.parententityname, t2.parententityname) as parententityname,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'AZBJ_PARTNER_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_AZBJ_PART_EXT_HIST' end, case when t2.parent_bk is not null then 'BJAZ_CLM_SUPP_EXTN' end, case when t3.parent_bk is not null then 'BJAZ_CP_PART_HIST' end, case when t4.parent_bk is not null then 'CP_PARTNERS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    )
