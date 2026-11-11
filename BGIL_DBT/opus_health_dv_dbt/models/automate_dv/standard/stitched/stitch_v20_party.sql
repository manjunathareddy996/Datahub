-- CENTRAL VIEW v20_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_DT_MEM (opus_health_legacy_v4)
--   BA_HCP_DT_MEM_COV (opus_health_legacy_v4)
--   BA_HCP_DT_POL_COV (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_CARD_DTLS (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GENERIC_LOADER_LOG_TABLE (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_ILLNESS_BASES_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_PARTY_CLAIM_HISTORY
--   SAT_POLICY_CERTIFICATE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_ROLE
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_PMSBY_DATA_WEB_SERVICE
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(trim(policy_ref),'') as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        doj as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
    where (nullif(trim(policy_ref),'')) is not null

    union all

    -- branch 1: BA_HCP_DT_MEM
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        mem_status as POLICY_CERTIFICATE__MEMBER_STATUS,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where (contract_id) is not null

    union all

    -- branch 2: BA_HCP_DT_MEM_COV
    select
        hcp_seqno as COVERAGE_BK,
        part_id as PARTY_BK,
        contract_id as POLICY_BK,
        1 as __LNK_PARTY_ROLE,
        1 as __LNK_POLICY_COVERAGE,
        1 as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        mem_add_flag as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        mem_status as POLICY_CERTIFICATE__MEMBER_STATUS,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where (coalesce(contract_id, hcp_seqno, part_id)) is not null

    union all

    -- branch 3: BA_HCP_DT_POL_COV
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        mem_add_flag as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        mem_status as POLICY_CERTIFICATE__MEMBER_STATUS,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where (contract_id) is not null

    union all

    -- branch 4: BGIL_GMC_FINAL_INSTL_DATA
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        policy_no as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        emp_code as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        annual_premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_inusred as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where (policy_no) is not null

    union all

    -- branch 5: BJAZ_CARD_DTLS
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        policy_ref as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        emp_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_card_dtls') }}
    where (policy_ref) is not null

    union all

    -- branch 6: BJAZ_EC_MEM_DTLS_EXTN
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        effetive_date as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        status as POLICY_CERTIFICATE__MEMBER_STATUS,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where (contract_id) is not null

    union all

    -- branch 7: BJAZ_GENERIC_LOADER_LOG_TABLE
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        pmasterpolicynumber as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        empno as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where (pmasterpolicynumber) is not null

    union all

    -- branch 8: BJAZ_GP_HOSPITAL_CASH
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        master_policy_no as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where (master_policy_no) is not null

    union all

    -- branch 9: BJAZ_HAT_ID_MEM_DETLS
    select
        cast(null as varchar) as COVERAGE_BK,
        member_no as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        prev_pol_clm_amt as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        member_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        join_date as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        status as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where (coalesce(contract_id, member_no)) is not null

    union all

    -- branch 10: BJAZ_HCF_MEMBER_DTLS
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        to_date as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        from_date as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1010 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 11: BJAZ_HC_PART_EXTN
    select
        cast(null as varchar) as COVERAGE_BK,
        part_id as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        amount_claimed as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1011 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where (coalesce(contract_id, part_id)) is not null

    union all

    -- branch 12: BJAZ_HDFC_SEC_FHPP
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        reference_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1012 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where (reference_id) is not null

    union all

    -- branch 13: BJAZ_HLT_ENSURE_MEM_DTLS
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        member_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1013 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 14: BJAZ_HM_COINSU_CLM_DTLS
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        policy_ref as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        emp_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1014 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where (policy_ref) is not null

    union all

    -- branch 15: BJAZ_HM_HCM_EXTRACT
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        policy as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1015 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where (policy) is not null

    union all

    -- branch 16: BJAZ_HM_INWARD_DTLS
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        policy_ref as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        certificate_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        certificate_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1016 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where (policy_ref) is not null

    union all

    -- branch 17: BJAZ_HM_MEMBER_DTLS
    select
        cast(null as varchar) as COVERAGE_BK,
        member_id as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        claim_count as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        member_id as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        member_status as POLICY_CERTIFICATE__MEMBER_STATUS,
        suminsured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1017 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where (coalesce(contract_id, member_id)) is not null

    union all

    -- branch 18: BJAZ_HM_ORPHAN_REG
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        policy_number as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        idcardno as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        suminsured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1018 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where (policy_number) is not null

    union all

    -- branch 19: BJAZ_IHG_MEM_DTLS_EXTN
    select
        cast(null as varchar) as COVERAGE_BK,
        member_no as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        amount_claimed as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        claim_history as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        member_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        effetive_date as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1019 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where (coalesce(contract_id, member_no)) is not null

    union all

    -- branch 20: BJAZ_ILLNESS_BASES_EXTN
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1020 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_illness_bases_extn') }}
    where (contract_id) is not null

    union all

    -- branch 21: BJAZ_SH_MEM_DTLS_EXTN
    select
        cast(null as varchar) as COVERAGE_BK,
        member_no as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        amount_claimed as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        claim_history as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        member_no as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        effetive_date as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1021 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where (coalesce(contract_id, member_no)) is not null

    union all

    -- branch 22: BJAZ_TPA_CLAIM_DETAILS_WS
    select
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        policy_no as POLICY_BK,
        cast(null as number) as __LNK_PARTY_ROLE,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__ENROLMENT_DATE,
        cast(null as varchar) as POLICY_CERTIFICATE__JOINING_TYPE,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        sum_insured as POLICY_CERTIFICATE__MEMBER_SUM_INSURED,
        1022 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where (policy_no) is not null

)

select
    COVERAGE_BK,
    PARTY_BK,
    POLICY_BK,
    __LNK_PARTY_ROLE,
    __LNK_POLICY_COVERAGE,
    __LNK_POLICY_PARTY,
    first_value(PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_AMOUNT,
    first_value(PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
    POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    first_value(POLICY_CERTIFICATE__CERTIFICATE_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
    first_value(POLICY_CERTIFICATE__COVERAGE_END_DATE) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
    first_value(POLICY_CERTIFICATE__COVERAGE_START_DATE) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
    first_value(POLICY_CERTIFICATE__ENROLMENT_DATE) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__ENROLMENT_DATE,
    first_value(POLICY_CERTIFICATE__JOINING_TYPE) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__JOINING_TYPE,
    first_value(POLICY_CERTIFICATE__MEMBER_PREMIUM) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
    first_value(POLICY_CERTIFICATE__MEMBER_STATUS) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__MEMBER_STATUS,
    first_value(POLICY_CERTIFICATE__MEMBER_SUM_INSURED) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__MEMBER_SUM_INSURED
from merged
