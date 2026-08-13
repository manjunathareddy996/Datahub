{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_POLICY_HEADER (HUB_POLICY grain).
-- Attribute-level merge across 31 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_policy_header.sql stage() model.

select parent_bk, cover_note_date, cover_note_reference, first_year_indicator, issue_date, master_policy_reference, policy_number, policy_remarks, policy_status, policy_term, policy_term_days, policy_type, premium_payer_reference, risk_expiry_date, risk_inception_date, risk_start_time, sum_insured_basis, sum_insured_total, top_up_policy_indicator, record_source
from (
    with t0 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(policy_status)), '') as policy_status,
            nullif(trim(to_varchar(policy_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(policy_start_date)), '') as risk_inception_date
        from {{ ref('stg_health__ba_hcp_pol_mst') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by policy_status, risk_expiry_date, risk_inception_date) = 1
    ),
         t1 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(inception_date)), '') as risk_inception_date,
            nullif(trim(to_varchar(top_indicator)), '') as top_up_policy_indicator
        from {{ ref('stg_health__ba_hcp_port_wordings') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by risk_inception_date, top_up_policy_indicator) = 1
    ),
         t2 as (
        select distinct
            base_policy_ref as parent_bk,
            nullif(trim(to_varchar(policy_period)), '') as policy_term
        from {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
        where base_policy_ref is not null
        qualify row_number() over (partition by parent_bk order by policy_term) = 1
    ),
         t3 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(pd_policy_period)), '') as policy_term,
            nullif(trim(to_varchar(pd_risk_inception_date)), '') as risk_inception_date,
            nullif(trim(to_varchar(pd_risk_inception_time_hhmm)), '') as risk_start_time
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by policy_term, risk_inception_date, risk_start_time) = 1
    ),
         t4 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(pd_policy_period)), '') as policy_term,
            nullif(trim(to_varchar(pd_risk_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(pd_risk_inception_date)), '') as risk_inception_date,
            nullif(trim(to_varchar(pd_risk_inception_time_hhmm)), '') as risk_start_time
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by policy_term, risk_expiry_date, risk_inception_date, risk_start_time) = 1
    ),
         t5 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(pd_policy_period)), '') as policy_term,
            nullif(trim(to_varchar(pd_risk_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(pd_risk_inception_date)), '') as risk_inception_date,
            nullif(trim(to_varchar(pd_risk_inception_time_hhmm)), '') as risk_start_time
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by policy_term, risk_expiry_date, risk_inception_date, risk_start_time) = 1
    ),
         t6 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(pd_master_policy_number)), '') as master_policy_reference,
            nullif(trim(to_varchar(pd_policy_period)), '') as policy_term,
            nullif(trim(to_varchar(pd_risk_inception_date)), '') as risk_inception_date,
            nullif(trim(to_varchar(pd_risk_inception_time_hhmm)), '') as risk_start_time
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by master_policy_reference, policy_term, risk_inception_date, risk_start_time) = 1
    ),
         t7 as (
        select distinct
            policy_no as parent_bk,
            nullif(trim(to_varchar(policy_expiry_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(policy_start_date)), '') as risk_inception_date
        from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
        where policy_no is not null
        qualify row_number() over (partition by parent_bk order by risk_expiry_date, risk_inception_date) = 1
    ),
         t8 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(no_of_years)), '') as policy_term,
            nullif(trim(to_varchar(term_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(term_start_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by policy_term, risk_expiry_date, risk_inception_date) = 1
    ),
         t9 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(status)), '') as policy_status,
            nullif(trim(to_varchar(policy_type)), '') as policy_type,
            nullif(trim(to_varchar(expiry_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(eff_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_card_dtls') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by policy_status, policy_type, risk_expiry_date, risk_inception_date) = 1
    ),
         t10 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(policy_status)), '') as policy_status,
            nullif(trim(to_varchar(policy_type)), '') as policy_type,
            nullif(trim(to_varchar(risk_expiry_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(risk_inception_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by policy_status, policy_type, risk_expiry_date, risk_inception_date) = 1
    ),
         t11 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(expiry_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(inception_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by risk_expiry_date, risk_inception_date) = 1
    ),
         t12 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(referenc_id)), '') as policy_number,
            nullif(trim(to_varchar(pol_period)), '') as policy_term,
            nullif(trim(to_varchar(term_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(term_start_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by policy_number, policy_term, risk_expiry_date, risk_inception_date) = 1
    ),
         t13 as (
        select distinct
            pmasterpolicynumber as parent_bk,
            nullif(trim(to_varchar(policyissuedate)), '') as issue_date,
            nullif(trim(to_varchar(premiumpayerid)), '') as premium_payer_reference,
            nullif(trim(to_varchar(ptodate)), '') as risk_expiry_date,
            nullif(trim(to_varchar(pstartdate)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
        where pmasterpolicynumber is not null
        qualify row_number() over (partition by parent_bk order by issue_date, premium_payer_reference, risk_expiry_date, risk_inception_date) = 1
    ),
         t14 as (
        select distinct
            reference_id as parent_bk,
            nullif(trim(to_varchar(policy_period)), '') as policy_term,
            nullif(trim(to_varchar(policy_type)), '') as policy_type,
            nullif(trim(to_varchar(risk_expiry_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(risk_inception_date)), '') as risk_inception_date,
            nullif(trim(to_varchar(risk_inception_time)), '') as risk_start_time
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where reference_id is not null
        qualify row_number() over (partition by parent_bk order by policy_term, policy_type, risk_expiry_date, risk_inception_date, risk_start_time) = 1
    ),
         t15 as (
        select distinct
            master_policy_no as parent_bk,
            nullif(trim(to_varchar(no_of_years)), '') as policy_term,
            nullif(trim(to_varchar(term_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(term_start_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
        where master_policy_no is not null
        qualify row_number() over (partition by parent_bk order by policy_term, risk_expiry_date, risk_inception_date) = 1
    ),
         t16 as (
        select distinct
            reg_no as parent_bk,
            nullif(trim(to_varchar(policy_period)), '') as policy_term,
            nullif(trim(to_varchar(policy_type)), '') as policy_type,
            nullif(trim(to_varchar(expiry_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(effective_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where reg_no is not null
        qualify row_number() over (partition by parent_bk order by policy_term, policy_type, risk_expiry_date, risk_inception_date) = 1
    ),
         t17 as (
        select distinct
            reg_no as parent_bk,
            nullif(trim(to_varchar(remarks_branch_ho)), '') as policy_remarks
        from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
        where reg_no is not null
        qualify row_number() over (partition by parent_bk order by policy_remarks) = 1
    ),
         t18 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(inception_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_hc_part_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by risk_inception_date) = 1
    ),
         t19 as (
        select distinct
            reference_id as parent_bk,
            nullif(trim(to_varchar(no_of_years)), '') as policy_term,
            nullif(trim(to_varchar(no_of_days)), '') as policy_term_days,
            nullif(trim(to_varchar(term_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(term_start_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
        where reference_id is not null
        qualify row_number() over (partition by parent_bk order by policy_term, policy_term_days, risk_expiry_date, risk_inception_date) = 1
    ),
         t20 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(policy_period)), '') as policy_term,
            nullif(trim(to_varchar(term_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(term_start_date)), '') as risk_inception_date,
            nullif(trim(to_varchar(si_flag)), '') as sum_insured_basis,
            nullif(trim(to_varchar(tot_plan_si)), '') as sum_insured_total
        from {{ ref('stg_health__bjaz_health_webservice_info') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by policy_term, risk_expiry_date, risk_inception_date, sum_insured_basis, sum_insured_total) = 1
    ),
         t21 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(pol_period)), '') as policy_term,
            nullif(trim(to_varchar(policy_type)), '') as policy_type,
            nullif(trim(to_varchar(term_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(term_start_date)), '') as risk_inception_date,
            nullif(trim(to_varchar(total_sum_insured)), '') as sum_insured_total
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by policy_term, policy_type, risk_expiry_date, risk_inception_date, sum_insured_total) = 1
    ),
         t22 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(valid_upto_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(comncmnt_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by risk_expiry_date, risk_inception_date) = 1
    ),
         t23 as (
        select distinct
            policy as parent_bk,
            nullif(trim(to_varchar(red)), '') as risk_expiry_date,
            nullif(trim(to_varchar(rid)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
        where policy is not null
        qualify row_number() over (partition by parent_bk order by risk_expiry_date, risk_inception_date) = 1
    ),
         t24 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(term_end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(term_start_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by risk_expiry_date, risk_inception_date) = 1
    ),
         t25 as (
        select distinct
            policy_number as parent_bk,
            nullif(trim(to_varchar(end_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(start_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
        where policy_number is not null
        qualify row_number() over (partition by parent_bk order by risk_expiry_date, risk_inception_date) = 1
    ),
         t26 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(expiry_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(inception_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by risk_expiry_date, risk_inception_date) = 1
    ),
         t27 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(covernote_date)), '') as cover_note_date,
            nullif(trim(to_varchar(covernote_no)), '') as cover_note_reference
        from {{ ref('stg_health__bjaz_illness_bases_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by cover_note_date, cover_note_reference) = 1
    ),
         t28 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(business_flg)), '') as first_year_indicator
        from {{ ref('stg_health__bjaz_pmjay_prmbook_dtls') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by first_year_indicator) = 1
    ),
         t29 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(period_of_insurance)), '') as policy_term,
            nullif(trim(to_varchar(expiry_date)), '') as risk_expiry_date,
            nullif(trim(to_varchar(inception_date)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by policy_term, risk_expiry_date, risk_inception_date) = 1
    ),
         t30 as (
        select distinct
            policy_no as parent_bk,
            nullif(trim(to_varchar(policy_type)), '') as policy_type,
            nullif(trim(to_varchar(policy_upto)), '') as risk_expiry_date,
            nullif(trim(to_varchar(policy_from)), '') as risk_inception_date
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where policy_no is not null
        qualify row_number() over (partition by parent_bk order by policy_type, risk_expiry_date, risk_inception_date) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk, t10.parent_bk, t11.parent_bk, t12.parent_bk, t13.parent_bk, t14.parent_bk, t15.parent_bk, t16.parent_bk, t17.parent_bk, t18.parent_bk, t19.parent_bk, t20.parent_bk, t21.parent_bk, t22.parent_bk, t23.parent_bk, t24.parent_bk, t25.parent_bk, t26.parent_bk, t27.parent_bk, t28.parent_bk, t29.parent_bk, t30.parent_bk) as parent_bk,
        coalesce(t27.cover_note_date) as cover_note_date,
        coalesce(t27.cover_note_reference) as cover_note_reference,
        coalesce(t28.first_year_indicator) as first_year_indicator,
        coalesce(t13.issue_date) as issue_date,
        coalesce(t6.master_policy_reference) as master_policy_reference,
        coalesce(t12.policy_number) as policy_number,
        coalesce(t17.policy_remarks) as policy_remarks,
        coalesce(t0.policy_status, t9.policy_status, t10.policy_status) as policy_status,
        coalesce(t2.policy_term, t3.policy_term, t4.policy_term, t5.policy_term, t6.policy_term, t8.policy_term, t12.policy_term, t14.policy_term, t15.policy_term, t16.policy_term, t19.policy_term, t20.policy_term, t21.policy_term, t29.policy_term) as policy_term,
        coalesce(t19.policy_term_days) as policy_term_days,
        coalesce(t9.policy_type, t10.policy_type, t14.policy_type, t16.policy_type, t21.policy_type, t30.policy_type) as policy_type,
        coalesce(t13.premium_payer_reference) as premium_payer_reference,
        coalesce(t0.risk_expiry_date, t4.risk_expiry_date, t5.risk_expiry_date, t7.risk_expiry_date, t8.risk_expiry_date, t9.risk_expiry_date, t10.risk_expiry_date, t11.risk_expiry_date, t12.risk_expiry_date, t13.risk_expiry_date, t14.risk_expiry_date, t15.risk_expiry_date, t16.risk_expiry_date, t19.risk_expiry_date, t20.risk_expiry_date, t21.risk_expiry_date, t22.risk_expiry_date, t23.risk_expiry_date, t24.risk_expiry_date, t25.risk_expiry_date, t26.risk_expiry_date, t29.risk_expiry_date, t30.risk_expiry_date) as risk_expiry_date,
        coalesce(t0.risk_inception_date, t1.risk_inception_date, t3.risk_inception_date, t4.risk_inception_date, t5.risk_inception_date, t6.risk_inception_date, t7.risk_inception_date, t8.risk_inception_date, t9.risk_inception_date, t10.risk_inception_date, t11.risk_inception_date, t12.risk_inception_date, t13.risk_inception_date, t14.risk_inception_date, t15.risk_inception_date, t16.risk_inception_date, t18.risk_inception_date, t19.risk_inception_date, t20.risk_inception_date, t21.risk_inception_date, t22.risk_inception_date, t23.risk_inception_date, t24.risk_inception_date, t25.risk_inception_date, t26.risk_inception_date, t29.risk_inception_date, t30.risk_inception_date) as risk_inception_date,
        coalesce(t3.risk_start_time, t4.risk_start_time, t5.risk_start_time, t6.risk_start_time, t14.risk_start_time) as risk_start_time,
        coalesce(t20.sum_insured_basis) as sum_insured_basis,
        coalesce(t20.sum_insured_total, t21.sum_insured_total) as sum_insured_total,
        coalesce(t1.top_up_policy_indicator) as top_up_policy_indicator,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_POL_MST' end, case when t1.parent_bk is not null then 'BA_HCP_PORT_WORDINGS' end, case when t2.parent_bk is not null then 'BA_HCP_PRIME_RIDER_DTLS' end, case when t3.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t4.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t5.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t6.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t7.parent_bk is not null then 'BGIL_GMC_FINAL_INSTL_DATA' end, case when t8.parent_bk is not null then 'BJAZ_BANDHAN_MEDI_CLAM' end, case when t9.parent_bk is not null then 'BJAZ_CARD_DTLS' end, case when t10.parent_bk is not null then 'BJAZ_ECARD_POL_DTLS_CONFIG' end, case when t11.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t12.parent_bk is not null then 'BJAZ_EHH_POL_DTLS' end, case when t13.parent_bk is not null then 'BJAZ_GENERIC_LOADER_LOG_TABLE' end, case when t14.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end, case when t15.parent_bk is not null then 'BJAZ_GP_HOSPITAL_CASH' end, case when t16.parent_bk is not null then 'BJAZ_GRP_HLT_DTLS' end, case when t17.parent_bk is not null then 'BJAZ_GRP_HLT_MATERNITY_DTLS' end, case when t18.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t19.parent_bk is not null then 'BJAZ_HDFC_SEC_FHPP' end, case when t20.parent_bk is not null then 'BJAZ_HEALTH_WEBSERVICE_INFO' end, case when t21.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end, case when t22.parent_bk is not null then 'BJAZ_HM_COINSU_CLM_DTLS' end, case when t23.parent_bk is not null then 'BJAZ_HM_HCM_EXTRACT' end, case when t24.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t25.parent_bk is not null then 'BJAZ_HM_ORPHAN_REG' end, case when t26.parent_bk is not null then 'BJAZ_IHG_MEM_DTLS_EXTN' end, case when t27.parent_bk is not null then 'BJAZ_ILLNESS_BASES_EXTN' end, case when t28.parent_bk is not null then 'BJAZ_PMJAY_PRMBOOK_DTLS' end, case when t29.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t30.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
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
    )
