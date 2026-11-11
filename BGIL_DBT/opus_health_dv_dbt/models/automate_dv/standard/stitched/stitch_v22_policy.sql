-- CENTRAL VIEW v22_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_NR_BASES_EXTN (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_UNDERWRITING
--   SAT_AUG_POLICY_CLASSIFICATION
--   SAT_AUG_POLICY_CONTINGENCY_SCHEME
--   SAT_POLICY_CLASSIFICATION
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_CTNGY_NR_BASES_EXTN
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        param_id as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        scheme_code as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        scheme_version as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        param_ref as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        param_ref as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        param_value as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ctngy_nr_bases_extn') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 1: BJAZ_ENROLL_SCR_DTLS
    select
        nullif(trim(scrutiny_no),'') as ASSESSMENT_BK,
        cast(null as varchar) as POLICY_BK,
        accpepted_si_by as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
    where (nullif(trim(scrutiny_no),'')) is not null

    union all

    -- branch 2: BJAZ_ENROLL_SCR_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TRANSACTION_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'TRANSACTION_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        transaction_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 3: BJAZ_ENROLL_SCR_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        buiseness_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 4: BJAZ_ENROLL_SCR_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=CRC_APPLICABLE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'CRC_APPLICABLE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        crcapplicable_yn as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 5: BJAZ_ENROLL_SCR_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=ENROLLMENT_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'ENROLLMENT_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        enrollment_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 6: BA_HCP_DT_PREMIUM | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        contract_id as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        buss_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where (contract_id) is not null

    union all

    -- branch 7: BA_HCP_PROD_8428_GPG_LOADER | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        pd_business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 8: BA_HCP_PROD_8432_ECP_LOADER
    select
        pd_scrutiny_number as ASSESSMENT_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        md_spcl_condtn_member_level as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where (pd_scrutiny_number) is not null

    union all

    -- branch 9: BA_HCP_PROD_8432_ECP_LOADER | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        pd_business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 10: BA_HCP_PROD_8433_FHC_LOADER | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        pd_business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 11: BA_HCP_PROD_8439_CLH_LOADER | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        pol_serial_no as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        pd_business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where (pol_serial_no) is not null

    union all

    -- branch 12: BGIL_GMC_FINAL_INSTL_DATA | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=GRADE_BUCKET
    select
        cast(null as varchar) as ASSESSMENT_BK,
        policy_no as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'GRADE_BUCKET' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        grade_bucket as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where (policy_no) is not null

    union all

    -- branch 13: BJAZ_BANDHAN_MEDI_CLAM
    select
        scrutiny_no as ASSESSMENT_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        uw_remark as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where (scrutiny_no) is not null

    union all

    -- branch 14: BJAZ_BANDHAN_MEDI_CLAM | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        policy_ref as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where (policy_ref) is not null

    union all

    -- branch 15: BJAZ_GPG_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        reference_id as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where (reference_id) is not null

    union all

    -- branch 16: BJAZ_GRP_HLT_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=INDUSTRY_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        reg_no as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'INDUSTRY_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        industry_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1010 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where (reg_no) is not null

    union all

    -- branch 17: BJAZ_GRP_HLT_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        reg_no as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1010 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where (reg_no) is not null

    union all

    -- branch 18: BJAZ_HEALTH_WEBSERVICE_INFO | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        policy_ref as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        1011 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where (policy_ref) is not null

    union all

    -- branch 19: BJAZ_POLICY_BASES_EXTN | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_SOURCE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_SOURCE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        business_source as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        2012 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_policy_bases_extn') }}
    where (nullif(trim(contract_id),'')) is not null

    union all

    -- branch 20: BJAZ_STARPKG_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(trim(contract_id),'') as POLICY_BK,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
        cast(null as varchar) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
        buss_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        2013 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}
    where (nullif(trim(contract_id),'')) is not null

)

select
    ASSESSMENT_BK,
    POLICY_BK,
    first_value(ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY,
    first_value(ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
    first_value(ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
    first_value(AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CODE,
    first_value(AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_CODE,
    first_value(AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_CONTINGENCY_SCHEME__SCHEME_VERSION,
    POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    first_value(POLICY_CLASSIFICATION__CLASSIFICATION_TYPE) ignore nulls over (partition by POLICY_BK, POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE,
    first_value(POLICY_CLASSIFICATION__CLASSIFICATION_VALUE) ignore nulls over (partition by POLICY_BK, POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE
from merged
