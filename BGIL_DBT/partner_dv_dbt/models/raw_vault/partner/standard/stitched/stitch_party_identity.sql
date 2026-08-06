{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_IDENTITY (HUB_PARTY grain).
-- 22 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, age, dateofbirth, dateofdeath, firstname, gendercode, lastname, middlename, namesuffix, nationality, partydisplayname, partyfullname, partylegalname, partyshortname, partystatus, partytypecode, placeofbirth, salutation, record_source
from (
    with t0 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(status)), '') as partystatus,
            nullif(trim(to_varchar(place_of_birth)), '') as placeofbirth
        from {{ ref('stg_partner__azbj_partner_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by partystatus, placeofbirth) = 1
    ),
         t1 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(member_name)), '') as partyfullname
        from {{ ref('stg_partner__ba_hcp_dt_mem') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by partyfullname) = 1
    ),
         t2 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(place_of_birth)), '') as placeofbirth
        from {{ ref('stg_partner__bjaz_azbj_part_ext_hist') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by placeofbirth) = 1
    ),
         t3 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(owners_name)), '') as firstname,
            nullif(trim(to_varchar(owners_sur_name)), '') as lastname,
            nullif(trim(to_varchar(owners_middle_name)), '') as middlename,
            nullif(trim(to_varchar(owners_full_name)), '') as partyfullname,
            nullif(trim(to_varchar(mfg_co_name)), '') as partylegalname
        from {{ ref('stg_partner__bjaz_clm_supp_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by firstname, lastname, middlename, partyfullname, partylegalname) = 1
    ),
         t4 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(date_of_death)), '') as dateofdeath,
            nullif(trim(to_varchar(first_name)), '') as firstname,
            nullif(trim(to_varchar(sex)), '') as gendercode,
            nullif(trim(to_varchar(surname)), '') as lastname,
            nullif(trim(to_varchar(middle_name)), '') as middlename,
            nullif(trim(to_varchar(after_title)), '') as namesuffix,
            nullif(trim(to_varchar(nationality)), '') as nationality,
            nullif(trim(to_varchar(name)), '') as partyfullname,
            nullif(trim(to_varchar(institution_name)), '') as partylegalname,
            nullif(trim(to_varchar(short_name)), '') as partyshortname,
            nullif(trim(to_varchar(partner_type)), '') as partytypecode,
            nullif(trim(to_varchar(before_title)), '') as salutation
        from {{ ref('stg_partner__bjaz_cp_part_hist') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by dateofbirth, dateofdeath, firstname, gendercode, lastname, middlename, namesuffix, nationality, partyfullname, partylegalname, partyshortname, partytypecode, salutation) = 1
    ),
         t5 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(dob)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(member_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_ctngy_ff_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by dateofbirth, gendercode, partyfullname) = 1
    ),
         t6 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(member_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_ctngy_gc_mem_data') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname) = 1
    ),
         t7 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(dob)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(last_name)), '') as lastname,
            nullif(trim(to_varchar(middle_name)), '') as middlename,
            nullif(trim(to_varchar(member_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_ctngy_pa_mem_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, lastname, middlename, partyfullname) = 1
    ),
         t8 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(name)), '') as partyfullname,
            nullif(trim(to_varchar(status)), '') as partystatus
        from {{ ref('stg_partner__bjaz_ec_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname, partystatus) = 1
    ),
         t9 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(insured_name)), '') as partyfullname,
            nullif(trim(to_varchar(company_name)), '') as partylegalname
        from {{ ref('stg_partner__bjaz_hcf_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname, partylegalname) = 1
    ),
         t10 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(sex)), '') as gendercode,
            nullif(trim(to_varchar(member_name)), '') as partyfullname,
            nullif(trim(to_varchar(status)), '') as partystatus
        from {{ ref('stg_partner__bjaz_hc_part_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname, partystatus) = 1
    ),
         t11 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_hlt_ensure_mem_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname) = 1
    ),
         t12 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(benname)), '') as partydisplayname,
            nullif(trim(to_varchar(hospital_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_hm_hospital_master') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by partydisplayname, partyfullname) = 1
    ),
         t13 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(dob)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(member_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_hm_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname) = 1
    ),
         t14 as (
        select distinct
            intermediary_id as parent_bk,
            nullif(trim(to_varchar(intermediary_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_intermediary') }}
        where intermediary_id is not null
        qualify row_number() over (partition by parent_bk order by partyfullname) = 1
    ),
         t15 as (
        select distinct
            intermediary_id as parent_bk,
            nullif(trim(to_varchar(intermediary_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_intermediary_hist') }}
        where intermediary_id is not null
        qualify row_number() over (partition by parent_bk order by partyfullname) = 1
    ),
         t16 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(dob)), '') as dateofbirth,
            nullif(trim(to_varchar(member_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_pa_detl_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, partyfullname) = 1
    ),
         t17 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(name)), '') as partyfullname,
            nullif(trim(to_varchar(company_name)), '') as partylegalname,
            nullif(trim(to_varchar(status)), '') as partystatus
        from {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname, partylegalname, partystatus) = 1
    ),
         t18 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(insured_name)), '') as partyfullname,
            nullif(trim(to_varchar(company_name)), '') as partylegalname
        from {{ ref('stg_partner__bjaz_spp_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname, partylegalname) = 1
    ),
         t19 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(dob)), '') as dateofbirth,
            nullif(trim(to_varchar(gender)), '') as gendercode,
            nullif(trim(to_varchar(member_name)), '') as partyfullname
        from {{ ref('stg_partner__bjaz_starpkg_ff_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by age, dateofbirth, gendercode, partyfullname) = 1
    ),
         t20 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(date_of_birth)), '') as dateofbirth,
            nullif(trim(to_varchar(date_of_death)), '') as dateofdeath,
            nullif(trim(to_varchar(first_name)), '') as firstname,
            nullif(trim(to_varchar(sex)), '') as gendercode,
            nullif(trim(to_varchar(surname)), '') as lastname,
            nullif(trim(to_varchar(middle_name)), '') as middlename,
            nullif(trim(to_varchar(after_title)), '') as namesuffix,
            nullif(trim(to_varchar(nationality)), '') as nationality,
            nullif(trim(to_varchar(name)), '') as partyfullname,
            nullif(trim(to_varchar(institution_name)), '') as partylegalname,
            nullif(trim(to_varchar(short_name)), '') as partyshortname,
            nullif(trim(to_varchar(partner_type)), '') as partytypecode,
            nullif(trim(to_varchar(before_title)), '') as salutation
        from {{ ref('stg_partner__cp_partners') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by dateofbirth, dateofdeath, firstname, gendercode, lastname, middlename, namesuffix, nationality, partyfullname, partylegalname, partyshortname, partytypecode, salutation) = 1
    ),
         t21 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(customer_name_text)), '') as partyfullname
        from {{ ref('stg_partner__ocp_interested_parties') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by partyfullname) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk, t10.parent_bk, t11.parent_bk, t12.parent_bk, t13.parent_bk, t14.parent_bk, t15.parent_bk, t16.parent_bk, t17.parent_bk, t18.parent_bk, t19.parent_bk, t20.parent_bk, t21.parent_bk) as parent_bk,
        coalesce(t6.age, t7.age, t8.age, t9.age, t10.age, t11.age, t13.age, t16.age, t17.age, t18.age, t19.age) as age,
        coalesce(t4.dateofbirth, t5.dateofbirth, t6.dateofbirth, t7.dateofbirth, t8.dateofbirth, t9.dateofbirth, t10.dateofbirth, t11.dateofbirth, t13.dateofbirth, t16.dateofbirth, t17.dateofbirth, t18.dateofbirth, t19.dateofbirth, t20.dateofbirth) as dateofbirth,
        coalesce(t4.dateofdeath, t20.dateofdeath) as dateofdeath,
        coalesce(t3.firstname, t4.firstname, t20.firstname) as firstname,
        coalesce(t4.gendercode, t5.gendercode, t6.gendercode, t7.gendercode, t8.gendercode, t9.gendercode, t10.gendercode, t11.gendercode, t13.gendercode, t17.gendercode, t18.gendercode, t19.gendercode, t20.gendercode) as gendercode,
        coalesce(t3.lastname, t4.lastname, t7.lastname, t20.lastname) as lastname,
        coalesce(t3.middlename, t4.middlename, t7.middlename, t20.middlename) as middlename,
        coalesce(t4.namesuffix, t20.namesuffix) as namesuffix,
        coalesce(t4.nationality, t20.nationality) as nationality,
        t12.partydisplayname as partydisplayname,
        coalesce(t1.partyfullname, t3.partyfullname, t4.partyfullname, t5.partyfullname, t6.partyfullname, t7.partyfullname, t8.partyfullname, t9.partyfullname, t10.partyfullname, t11.partyfullname, t12.partyfullname, t13.partyfullname, t14.partyfullname, t15.partyfullname, t16.partyfullname, t17.partyfullname, t18.partyfullname, t19.partyfullname, t20.partyfullname, t21.partyfullname) as partyfullname,
        coalesce(t3.partylegalname, t4.partylegalname, t9.partylegalname, t17.partylegalname, t18.partylegalname, t20.partylegalname) as partylegalname,
        coalesce(t4.partyshortname, t20.partyshortname) as partyshortname,
        coalesce(t0.partystatus, t8.partystatus, t10.partystatus, t17.partystatus) as partystatus,
        coalesce(t4.partytypecode, t20.partytypecode) as partytypecode,
        coalesce(t0.placeofbirth, t2.placeofbirth) as placeofbirth,
        coalesce(t4.salutation, t20.salutation) as salutation,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'AZBJ_PARTNER_EXTN' end, case when t1.parent_bk is not null then 'BA_HCP_DT_MEM' end, case when t2.parent_bk is not null then 'BJAZ_AZBJ_PART_EXT_HIST' end, case when t3.parent_bk is not null then 'BJAZ_CLM_SUPP_EXTN' end, case when t4.parent_bk is not null then 'BJAZ_CP_PART_HIST' end, case when t5.parent_bk is not null then 'BJAZ_CTNGY_FF_DTLS_EXTN' end, case when t6.parent_bk is not null then 'BJAZ_CTNGY_GC_MEM_DATA' end, case when t7.parent_bk is not null then 'BJAZ_CTNGY_PA_MEM_DTLS' end, case when t8.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t9.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t10.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t11.parent_bk is not null then 'BJAZ_HLT_ENSURE_MEM_DTLS' end, case when t12.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER' end, case when t13.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t14.parent_bk is not null then 'BJAZ_INTERMEDIARY' end, case when t15.parent_bk is not null then 'BJAZ_INTERMEDIARY_HIST' end, case when t16.parent_bk is not null then 'BJAZ_PA_DETL_EXTN' end, case when t17.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t18.parent_bk is not null then 'BJAZ_SPP_MEMBER_DTLS' end, case when t19.parent_bk is not null then 'BJAZ_STARPKG_FF_DTLS' end, case when t20.parent_bk is not null then 'CP_PARTNERS' end, case when t21.parent_bk is not null then 'OCP_INTERESTED_PARTIES' end), ', ') as record_source
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
    full outer join t10 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk) = t10.parent_bk
    full outer join t11 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk) = t11.parent_bk
    full outer join t12 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk) = t12.parent_bk
    full outer join t13 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk) = t13.parent_bk
    full outer join t14 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk) = t14.parent_bk
    full outer join t15 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk) = t15.parent_bk
    full outer join t16 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk) = t16.parent_bk
    full outer join t17 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk) = t17.parent_bk
    full outer join t18 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk) = t18.parent_bk
    full outer join t19 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk) = t19.parent_bk
    full outer join t20 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk) = t20.parent_bk
    full outer join t21 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk) = t21.parent_bk
    )
