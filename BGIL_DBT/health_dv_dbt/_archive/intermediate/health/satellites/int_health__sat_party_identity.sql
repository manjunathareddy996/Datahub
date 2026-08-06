-- Intermediate harmonisation view for SAT_PARTY_IDENTITY (HUB_PARTY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 48 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, age, date_of_birth, first_name, gender_code, last_name, middle_name, party_display_name, party_full_name, party_legal_name, party_status, party_status_reason, party_sub_type_code, party_type_code, salutation, record_source
from (
    with t0 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(member_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_dt_mem') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t1 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(member_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t2 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(member_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t3 as (
        select distinct
            user_id as parent_bk,
            nullif(trim(to_varchar(member_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_pol_mst') }}
        where user_id is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t4 as (
        select distinct
            alloted_to as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(member_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
        where alloted_to is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, party_full_name) = 1
    ),
         t5 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(md_first_name)), '') as first_name,
            nullif(trim(to_varchar(md_gender)), '') as gender_code,
            nullif(trim(to_varchar(md_last_name)), '') as last_name,
            nullif(trim(to_varchar(md_middle_name)), '') as middle_name
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by date_of_birth, first_name, gender_code, last_name, middle_name) = 1
    ),
         t6 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(md_first_name)), '') as first_name,
            nullif(trim(to_varchar(md_gender)), '') as gender_code,
            nullif(trim(to_varchar(md_last_name)), '') as last_name,
            nullif(trim(to_varchar(md_middle_name)), '') as middle_name
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by date_of_birth, first_name, gender_code, last_name, middle_name) = 1
    ),
         t7 as (
        select distinct
            pd_imd_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_imd_rm_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_imd_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t8 as (
        select distinct
            pd_bagic_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_bagic_rm_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_bagic_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t9 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(md_first_name)), '') as first_name,
            nullif(trim(to_varchar(md_gender)), '') as gender_code,
            nullif(trim(to_varchar(md_last_name)), '') as last_name,
            nullif(trim(to_varchar(md_middle_name)), '') as middle_name,
            nullif(trim(to_varchar(plc_institution_name)), '') as party_legal_name
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by date_of_birth, first_name, gender_code, last_name, middle_name, party_legal_name) = 1
    ),
         t10 as (
        select distinct
            pd_imd_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_imd_rm_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_imd_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t11 as (
        select distinct
            pd_bagic_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_bagic_rm_name)), '') as party_full_name
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_bagic_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t12 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(md_first_name)), '') as first_name,
            nullif(trim(to_varchar(md_gender)), '') as gender_code,
            nullif(trim(to_varchar(md_last_name)), '') as last_name,
            nullif(trim(to_varchar(md_middle_name)), '') as middle_name
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by date_of_birth, first_name, gender_code, last_name, middle_name) = 1
    ),
         t13 as (
        select distinct
            emp_code as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(emp_name)), '') as party_full_name
        from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
        where emp_code is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, party_full_name) = 1
    ),
         t14 as (
        select distinct
            customer_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(dob)), '') as date_of_birth,
            nullif(trim(to_varchar(first_name)), '') as first_name,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(last_name)), '') as last_name,
            nullif(trim(to_varchar(middle_name)), '') as middle_name,
            nullif(trim(to_varchar(customer_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
        where customer_id is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, first_name, gender_code, last_name, middle_name, party_full_name) = 1
    ),
         t15 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name) = 1
    ),
         t16 as (
        select distinct
            emp_code as parent_bk,
            nullif(trim(to_varchar(age)), '') as age
        from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
        where emp_code is not null
        qualify row_number() over (partition by parent_bk order by age) = 1
    ),
         t17 as (
        select distinct
            user_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age
        from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
        where user_id is not null
        qualify row_number() over (partition by parent_bk order by age) = 1
    ),
         t18 as (
        select distinct
            imd_code as parent_bk,
            nullif(trim(to_varchar(imd_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where imd_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t19 as (
        select distinct
            bagic_rm_e_code as parent_bk,
            nullif(trim(to_varchar(bagic_rm_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where bagic_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t20 as (
        select distinct
            sub_imd_code as parent_bk,
            nullif(trim(to_varchar(sub_imd_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where sub_imd_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t21 as (
        select distinct
            user_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(dob)), '') as date_of_birth,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(customer_name)), '') as party_full_name,
            nullif(trim(to_varchar(customer_type)), '') as party_type_code
        from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
        where user_id is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name, party_type_code) = 1
    ),
         t22 as (
        select distinct
            imd_code as parent_bk,
            nullif(trim(to_varchar(imd_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
        where imd_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t23 as (
        select distinct
            rm_code as parent_bk,
            nullif(trim(to_varchar(rm_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
        where rm_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t24 as (
        select distinct
            sub_imd_code as parent_bk,
            nullif(trim(to_varchar(sub_imd_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
        where sub_imd_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t25 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(first_name)), '') as first_name,
            nullif(trim(to_varchar(sex)), '') as gender_code,
            nullif(trim(to_varchar(last_name)), '') as last_name,
            nullif(trim(to_varchar(middle_name)), '') as middle_name,
            nullif(trim(to_varchar(emp_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, first_name, gender_code, last_name, middle_name, party_full_name) = 1
    ),
         t26 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(insured_name)), '') as party_full_name,
            nullif(trim(to_varchar(company_name)), '') as party_legal_name
        from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name, party_legal_name) = 1
    ),
         t27 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(sex)), '') as gender_code,
            nullif(trim(to_varchar(member_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hc_part_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name) = 1
    ),
         t28 as (
        select distinct
            client_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(dob)), '') as date_of_birth,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(customer_name)), '') as party_full_name,
            nullif(trim(to_varchar(customer_type)), '') as party_type_code
        from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
        where client_id is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name, party_type_code) = 1
    ),
         t29 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(first_name)), '') as first_name,
            nullif(trim(to_varchar(last_name)), '') as last_name
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by date_of_birth, first_name, last_name) = 1
    ),
         t30 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name) = 1
    ),
         t31 as (
        select distinct
            hospital_id as parent_bk,
            nullif(trim(to_varchar(patient_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
        where hospital_id is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t32 as (
        select distinct
            ldr_pid as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(sex)), '') as gender_code,
            nullif(trim(to_varchar(name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
        where ldr_pid is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name) = 1
    ),
         t33 as (
        select distinct
            hospital_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(processor)), '') as party_display_name,
            nullif(trim(to_varchar(insured)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where hospital_id is not null
        qualify row_number() over (partition by parent_bk order by age, gender_code, party_display_name, party_full_name) = 1
    ),
         t34 as (
        select distinct
            hospital_id as parent_bk,
            nullif(trim(to_varchar(hospital)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where hospital_id is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t35 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(hospital_name)), '') as party_full_name,
            nullif(trim(to_varchar(hosp_type)), '') as party_sub_type_code
        from {{ ref('stg_health__bjaz_hm_hospital_master') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by party_full_name, party_sub_type_code) = 1
    ),
         t36 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(initiated_by)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t37 as (
        select distinct
            hosid as parent_bk,
            nullif(trim(to_varchar(delistedhosp)), '') as party_status,
            nullif(trim(to_varchar(delistedhospreason)), '') as party_status_reason,
            nullif(trim(to_varchar(hospcatg)), '') as party_sub_type_code,
            nullif(trim(to_varchar(pcatghosp)), '') as party_type_code
        from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
        where hosid is not null
        qualify row_number() over (partition by parent_bk order by party_status, party_status_reason, party_sub_type_code, party_type_code) = 1
    ),
         t38 as (
        select distinct
            courier_id as parent_bk,
            nullif(trim(to_varchar(sender_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
        where courier_id is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t39 as (
        select distinct
            member_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(dob)), '') as date_of_birth,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(member_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where member_id is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name) = 1
    ),
         t40 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(name)), '') as party_full_name,
            nullif(trim(to_varchar(company_name)), '') as party_legal_name
        from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name, party_legal_name) = 1
    ),
         t41 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(age)), '') as age
        from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by age) = 1
    ),
         t42 as (
        select distinct
            payer_code as parent_bk,
            nullif(trim(to_varchar(payer_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where payer_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t43 as (
        select distinct
            remedinet_provider_code as parent_bk,
            nullif(trim(to_varchar(provider_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
        where remedinet_provider_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    ),
         t44 as (
        select distinct
            member_identifier as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(insured_dob)), '') as date_of_birth,
            nullif(trim(to_varchar(insured_gender)), '') as gender_code,
            nullif(trim(to_varchar(insured_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
        where member_identifier is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name) = 1
    ),
         t45 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(age)), '') as age,
            nullif(trim(to_varchar(date_of_birth)), '') as date_of_birth,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(name)), '') as party_full_name,
            nullif(trim(to_varchar(company_name)), '') as party_legal_name
        from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by age, date_of_birth, gender_code, party_full_name, party_legal_name) = 1
    ),
         t46 as (
        select distinct
            customer_id as parent_bk,
            nullif(trim(to_varchar(patient_age)), '') as age,
            nullif(trim(to_varchar(gender)), '') as gender_code,
            nullif(trim(to_varchar(proposer_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where customer_id is not null
        qualify row_number() over (partition by parent_bk order by age, gender_code, party_full_name) = 1
    ),
         t47 as (
        select distinct
            hospital_code as parent_bk,
            nullif(trim(to_varchar(hospital_name)), '') as party_full_name
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where hospital_code is not null
        qualify row_number() over (partition by parent_bk order by party_full_name) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk, t10.parent_bk, t11.parent_bk, t12.parent_bk, t13.parent_bk, t14.parent_bk, t15.parent_bk, t16.parent_bk, t17.parent_bk, t18.parent_bk, t19.parent_bk, t20.parent_bk, t21.parent_bk, t22.parent_bk, t23.parent_bk, t24.parent_bk, t25.parent_bk, t26.parent_bk, t27.parent_bk, t28.parent_bk, t29.parent_bk, t30.parent_bk, t31.parent_bk, t32.parent_bk, t33.parent_bk, t34.parent_bk, t35.parent_bk, t36.parent_bk, t37.parent_bk, t38.parent_bk, t39.parent_bk, t40.parent_bk, t41.parent_bk, t42.parent_bk, t43.parent_bk, t44.parent_bk, t45.parent_bk, t46.parent_bk, t47.parent_bk) as parent_bk,
        coalesce(t4.age, t13.age, t14.age, t15.age, t16.age, t17.age, t21.age, t25.age, t26.age, t27.age, t28.age, t30.age, t32.age, t33.age, t39.age, t40.age, t41.age, t44.age, t45.age, t46.age) as age,
        coalesce(t4.date_of_birth, t5.date_of_birth, t6.date_of_birth, t9.date_of_birth, t12.date_of_birth, t13.date_of_birth, t14.date_of_birth, t15.date_of_birth, t21.date_of_birth, t25.date_of_birth, t26.date_of_birth, t27.date_of_birth, t28.date_of_birth, t29.date_of_birth, t30.date_of_birth, t32.date_of_birth, t39.date_of_birth, t40.date_of_birth, t44.date_of_birth, t45.date_of_birth) as date_of_birth,
        coalesce(t5.first_name, t6.first_name, t9.first_name, t12.first_name, t14.first_name, t25.first_name, t29.first_name) as first_name,
        coalesce(t5.gender_code, t6.gender_code, t9.gender_code, t12.gender_code, t14.gender_code, t15.gender_code, t21.gender_code, t25.gender_code, t26.gender_code, t27.gender_code, t28.gender_code, t30.gender_code, t32.gender_code, t33.gender_code, t39.gender_code, t40.gender_code, t44.gender_code, t45.gender_code, t46.gender_code) as gender_code,
        coalesce(t5.last_name, t6.last_name, t9.last_name, t12.last_name, t14.last_name, t25.last_name, t29.last_name) as last_name,
        coalesce(t5.middle_name, t6.middle_name, t9.middle_name, t12.middle_name, t14.middle_name, t25.middle_name) as middle_name,
        coalesce(t33.party_display_name) as party_display_name,
        coalesce(t0.party_full_name, t1.party_full_name, t2.party_full_name, t3.party_full_name, t4.party_full_name, t7.party_full_name, t8.party_full_name, t10.party_full_name, t11.party_full_name, t13.party_full_name, t14.party_full_name, t15.party_full_name, t18.party_full_name, t19.party_full_name, t20.party_full_name, t21.party_full_name, t22.party_full_name, t23.party_full_name, t24.party_full_name, t25.party_full_name, t26.party_full_name, t27.party_full_name, t28.party_full_name, t30.party_full_name, t31.party_full_name, t32.party_full_name, t33.party_full_name, t34.party_full_name, t35.party_full_name, t36.party_full_name, t38.party_full_name, t39.party_full_name, t40.party_full_name, t42.party_full_name, t43.party_full_name, t44.party_full_name, t45.party_full_name, t46.party_full_name, t47.party_full_name) as party_full_name,
        coalesce(t9.party_legal_name, t26.party_legal_name, t40.party_legal_name, t45.party_legal_name) as party_legal_name,
        coalesce(t37.party_status) as party_status,
        coalesce(t37.party_status_reason) as party_status_reason,
        coalesce(t35.party_sub_type_code, t37.party_sub_type_code) as party_sub_type_code,
        coalesce(t21.party_type_code, t28.party_type_code, t37.party_type_code) as party_type_code,
        cast(null as varchar) as salutation,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_DT_MEM' end, case when t1.parent_bk is not null then 'BA_HCP_DT_MEM_COV' end, case when t2.parent_bk is not null then 'BA_HCP_DT_POL_COV' end, case when t3.parent_bk is not null then 'BA_HCP_POL_MST' end, case when t4.parent_bk is not null then 'BA_HCP_PP_MEM_DTLS' end, case when t5.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t6.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t7.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t8.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t9.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t10.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t11.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t12.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t13.parent_bk is not null then 'BGIL_GMC_FINAL_INSTL_DATA' end, case when t14.parent_bk is not null then 'BJAZ_BANDHAN_MEDI_CLAM' end, case when t15.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t16.parent_bk is not null then 'BJAZ_EWR_POL_DTLS' end, case when t17.parent_bk is not null then 'BJAZ_GC_GROUP_GUARD_DTLS' end, case when t18.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end, case when t19.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end, case when t20.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end, case when t21.parent_bk is not null then 'BJAZ_GP_HOSPITAL_CASH' end, case when t22.parent_bk is not null then 'BJAZ_GRP_HLT_IMD_DTLS' end, case when t23.parent_bk is not null then 'BJAZ_GRP_HLT_IMD_DTLS' end, case when t24.parent_bk is not null then 'BJAZ_GRP_HLT_IMD_DTLS' end, case when t25.parent_bk is not null then 'BJAZ_HAT_ID_MEM_DETLS' end, case when t26.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t27.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t28.parent_bk is not null then 'BJAZ_HDFC_SEC_FHPP' end, case when t29.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end, case when t30.parent_bk is not null then 'BJAZ_HLT_ENSURE_MEM_DTLS' end, case when t31.parent_bk is not null then 'BJAZ_HM_CASHLESS_INWARD' end, case when t32.parent_bk is not null then 'BJAZ_HM_COINSU_CLM_DTLS' end, case when t33.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t34.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t35.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER' end, case when t36.parent_bk is not null then 'BJAZ_HM_HOSPITAL_MASTER_EXTN' end, case when t37.parent_bk is not null then 'BJAZ_HM_HOSP_MASTER_EXTN1' end, case when t38.parent_bk is not null then 'BJAZ_HM_INWARD_DTLS' end, case when t39.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t40.parent_bk is not null then 'BJAZ_IHG_MEM_DTLS_EXTN' end, case when t41.parent_bk is not null then 'BJAZ_PC_ONLINE_POL_DTLS_MV' end, case when t42.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end, case when t43.parent_bk is not null then 'BJAZ_REMEDINET_CLAIM_DETAILS' end, case when t44.parent_bk is not null then 'BJAZ_SCR_HLTH_PORTABLE_DTLS' end, case when t45.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t46.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end, case when t47.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
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
    full outer join t22 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk) = t22.parent_bk
    full outer join t23 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk) = t23.parent_bk
    full outer join t24 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk) = t24.parent_bk
    full outer join t25 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk) = t25.parent_bk
    full outer join t26 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk) = t26.parent_bk
    full outer join t27 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk) = t27.parent_bk
    full outer join t28 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk) = t28.parent_bk
    full outer join t29 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk) = t29.parent_bk
    full outer join t30 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk) = t30.parent_bk
    full outer join t31 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk) = t31.parent_bk
    full outer join t32 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk) = t32.parent_bk
    full outer join t33 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk) = t33.parent_bk
    full outer join t34 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk) = t34.parent_bk
    full outer join t35 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk) = t35.parent_bk
    full outer join t36 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk) = t36.parent_bk
    full outer join t37 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk) = t37.parent_bk
    full outer join t38 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk) = t38.parent_bk
    full outer join t39 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk) = t39.parent_bk
    full outer join t40 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk), t39.parent_bk) = t40.parent_bk
    full outer join t41 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk), t39.parent_bk), t40.parent_bk) = t41.parent_bk
    full outer join t42 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk), t39.parent_bk), t40.parent_bk), t41.parent_bk) = t42.parent_bk
    full outer join t43 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk), t39.parent_bk), t40.parent_bk), t41.parent_bk), t42.parent_bk) = t43.parent_bk
    full outer join t44 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk), t39.parent_bk), t40.parent_bk), t41.parent_bk), t42.parent_bk), t43.parent_bk) = t44.parent_bk
    full outer join t45 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk), t39.parent_bk), t40.parent_bk), t41.parent_bk), t42.parent_bk), t43.parent_bk), t44.parent_bk) = t45.parent_bk
    full outer join t46 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk), t39.parent_bk), t40.parent_bk), t41.parent_bk), t42.parent_bk), t43.parent_bk), t44.parent_bk), t45.parent_bk) = t46.parent_bk
    full outer join t47 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk), t17.parent_bk), t18.parent_bk), t19.parent_bk), t20.parent_bk), t21.parent_bk), t22.parent_bk), t23.parent_bk), t24.parent_bk), t25.parent_bk), t26.parent_bk), t27.parent_bk), t28.parent_bk), t29.parent_bk), t30.parent_bk), t31.parent_bk), t32.parent_bk), t33.parent_bk), t34.parent_bk), t35.parent_bk), t36.parent_bk), t37.parent_bk), t38.parent_bk), t39.parent_bk), t40.parent_bk), t41.parent_bk), t42.parent_bk), t43.parent_bk), t44.parent_bk), t45.parent_bk), t46.parent_bk) = t47.parent_bk
    )
