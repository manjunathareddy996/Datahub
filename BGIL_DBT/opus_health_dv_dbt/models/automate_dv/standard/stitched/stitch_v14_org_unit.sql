-- CENTRAL VIEW v14_org_unit -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_BRANCH_MASTER (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_SH_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_ORG_UNIT_CONTACT
--   SAT_AUG_ORG_UNIT_DEFINITION
--   SAT_AUG_PARTY_EMPLOYMENT
--   SAT_ORG_UNIT_DEFINITION
--   SAT_ORG_UNIT_LICENCE
--   SAT_POLICY_BONUS_TRACKING
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_BRANCH_MASTER
    select
        nullif(trim(branch_code),'') as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        coalesce(email, itc_email_id) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        fax as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        coalesce(ren_telephone1, telephone1, telephone2) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        account_category_code as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        nearest_dm_branch as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        reason_for_act_deact as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        register_flag as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        record_date as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        branch_type as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        bm_username as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        branch_name as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        act_inact_status as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        parent_branch_code as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        print_zone as ORG_UNIT_DEFINITION__ZONE_NAME,
        bagic_gstn as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_branch_master') }}
    where (nullif(trim(branch_code),'')) is not null

    union all

    -- branch 1: BA_HCP_DT_PREMIUM
    select
        cast(null as varchar) as ORG_UNIT_BK,
        user_id as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        emp_no as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        cumulative_bonus_amt as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cumulative_bonus_rate as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where (coalesce(contract_id, user_id)) is not null

    union all

    -- branch 2: BA_HCP_PROD_8433_FHC_LOADER
    select
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        plc_cb_amount as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        plc_cb_per as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 3: BJAZ_HCF_MEMBER_DTLS
    select
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        cumulative_amt as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cumulative_bnouz_per as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where (contract_id) is not null

    union all

    -- branch 4: BJAZ_HM_MEMBER_DTLS
    select
        cast(null as varchar) as ORG_UNIT_BK,
        member_id as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        monthly_salary as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        cumm_bonus as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cumm_bonus_per as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where (coalesce(contract_id, member_id)) is not null

    union all

    -- branch 5: BJAZ_IHG_MEM_DTLS_EXTN
    select
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        cumm_bonus as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cumm_bonus_per as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where (contract_id) is not null

    union all

    -- branch 6: BJAZ_SH_MEM_DTLS_EXTN
    select
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        cumm_bonus as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cumm_bonus_per as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where (contract_id) is not null

    union all

    -- branch 7: BJAZ_TPA_CLAIM_DETAILS_WS
    select
        operating_office as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        policy_no as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        operating_code as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        coalesce(controlling_office, operating_office) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        bonus as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where (coalesce(operating_office, policy_no)) is not null

    union all

    -- branch 8: BJAZ_POLICY_BASES_EXTN
    select
        nullif(trim(department_code),'') as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        dm_location as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cast(null as varchar) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        ncb_rate as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        2008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_policy_bases_extn') }}
    where (coalesce(nullif(trim(contract_id),''), nullif(trim(department_code),''))) is not null

    union all

    -- branch 9: BJAZ_STARPKG_POL_DTLS
    select
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
        cast(null as varchar) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
        cb_amt as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
        cb_per as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        2009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}
    where (nullif(trim(contract_id),'')) is not null

)

select
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    first_value(AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__EMAIL_ADDRESS,
    first_value(AUG_ORG_UNIT_CONTACT__FAX_NUMBER) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__FAX_NUMBER,
    first_value(AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_CONTACT__LANDLINE_NUMBER,
    first_value(AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__ACCOUNTING_CATEGORY_CODE,
    first_value(AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__NEAREST_CONTROLLING_ORG_UNIT_REFERENCE,
    first_value(AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__ORG_UNIT_STATUS_REASON,
    first_value(AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__REGISTRATION_INDICATOR,
    first_value(AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__SOURCE_RECORD_DATE,
    first_value(AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__EMPLOYEE_NUMBER,
    first_value(AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__MONTHLY_SALARY_AMOUNT,
    first_value(ORG_UNIT_DEFINITION__BRANCH_TYPE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__BRANCH_TYPE,
    first_value(ORG_UNIT_DEFINITION__HEAD_REFERENCE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__HEAD_REFERENCE,
    first_value(ORG_UNIT_DEFINITION__ORG_UNIT_CODE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ORG_UNIT_CODE,
    first_value(ORG_UNIT_DEFINITION__ORG_UNIT_NAME) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    first_value(ORG_UNIT_DEFINITION__ORG_UNIT_STATUS) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ORG_UNIT_STATUS,
    first_value(ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    first_value(ORG_UNIT_DEFINITION__ZONE_NAME) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ZONE_NAME,
    first_value(ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_LICENCE__GST_REGISTRATION_NUMBER,
    first_value(POLICY_BONUS_TRACKING__BONUS_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__BONUS_AMOUNT,
    first_value(POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE,
    first_value(POLICY_BONUS_TRACKING__NCB_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE
from merged
