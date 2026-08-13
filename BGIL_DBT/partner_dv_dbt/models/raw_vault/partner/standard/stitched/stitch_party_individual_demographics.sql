{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS (HUB_PARTY grain).
-- 10 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, annualhouseholdincome, annualincome, designation, educationalqualification, fathername, maritalstatus, numberofchildren, occupationcode, occupationdescription, spousename, record_source
from (
    with t0 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(family_monthly_income)), '') as annualhouseholdincome,
            nullif(trim(to_varchar(education)), '') as educationalqualification,
            nullif(trim(to_varchar(father_name)), '') as fathername,
            nullif(trim(to_varchar(no_of_children)), '') as numberofchildren,
            nullif(trim(to_varchar(occupation_desc_gen)), '') as occupationdescription,
            nullif(trim(to_varchar(spouse_name)), '') as spousename
        from {{ ref('stg_partner__azbj_partner_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by annualhouseholdincome, educationalqualification, fathername, numberofchildren, occupationdescription, spousename) = 1
    ),
         t1 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(education)), '') as educationalqualification,
            nullif(trim(to_varchar(father_name)), '') as fathername,
            nullif(trim(to_varchar(occupation_desc_gen)), '') as occupationdescription
        from {{ ref('stg_partner__bjaz_azbj_part_ext_hist') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by educationalqualification, fathername, occupationdescription) = 1
    ),
         t2 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(marital_status)), '') as maritalstatus,
            nullif(trim(to_varchar(occupation)), '') as occupationcode
        from {{ ref('stg_partner__bjaz_cp_part_hist') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by maritalstatus, occupationcode) = 1
    ),
         t3 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(gross_income)), '') as annualincome,
            nullif(trim(to_varchar(occupation)), '') as occupationcode
        from {{ ref('stg_partner__bjaz_ec_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by annualincome, occupationcode) = 1
    ),
         t4 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(monthly_income)), '') as annualincome,
            nullif(trim(to_varchar(member_occupation)), '') as occupationcode
        from {{ ref('stg_partner__bjaz_hcf_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by annualincome, occupationcode) = 1
    ),
         t5 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(occupation)), '') as occupationcode
        from {{ ref('stg_partner__bjaz_hc_part_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by occupationcode) = 1
    ),
         t6 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(gross_income)), '') as annualincome,
            nullif(trim(to_varchar(designation)), '') as designation,
            nullif(trim(to_varchar(occupation)), '') as occupationcode
        from {{ ref('stg_partner__bjaz_hm_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by annualincome, designation, occupationcode) = 1
    ),
         t7 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(gross_income)), '') as annualincome,
            nullif(trim(to_varchar(occupation)), '') as occupationcode
        from {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by annualincome, occupationcode) = 1
    ),
         t8 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(member_occupation)), '') as occupationcode
        from {{ ref('stg_partner__bjaz_spp_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by occupationcode) = 1
    ),
         t9 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(marital_status)), '') as maritalstatus,
            nullif(trim(to_varchar(occupation)), '') as occupationcode
        from {{ ref('stg_partner__cp_partners') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by maritalstatus, occupationcode) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk) as parent_bk,
        t0.annualhouseholdincome as annualhouseholdincome,
        coalesce(t3.annualincome, t4.annualincome, t6.annualincome, t7.annualincome) as annualincome,
        t6.designation as designation,
        coalesce(t0.educationalqualification, t1.educationalqualification) as educationalqualification,
        coalesce(t0.fathername, t1.fathername) as fathername,
        coalesce(t2.maritalstatus, t9.maritalstatus) as maritalstatus,
        t0.numberofchildren as numberofchildren,
        coalesce(t2.occupationcode, t3.occupationcode, t4.occupationcode, t5.occupationcode, t6.occupationcode, t7.occupationcode, t8.occupationcode, t9.occupationcode) as occupationcode,
        coalesce(t0.occupationdescription, t1.occupationdescription) as occupationdescription,
        t0.spousename as spousename,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'AZBJ_PARTNER_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_AZBJ_PART_EXT_HIST' end, case when t2.parent_bk is not null then 'BJAZ_CP_PART_HIST' end, case when t3.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t4.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t5.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t6.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t7.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t8.parent_bk is not null then 'BJAZ_SPP_MEMBER_DTLS' end, case when t9.parent_bk is not null then 'CP_PARTNERS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    full outer join t8 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk) = t8.parent_bk
    full outer join t9 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk) = t9.parent_bk
    )
