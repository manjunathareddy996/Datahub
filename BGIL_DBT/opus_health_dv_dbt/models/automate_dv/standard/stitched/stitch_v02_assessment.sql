-- CENTRAL VIEW v02_assessment -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BA_HCP_PP_MEM_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_SCR_HLTH_PORTABLE_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_GRP_HLT_MEM_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_HEADER
--   SAT_QUOTE_HEADER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_CASE_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_QUOTE_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_ENROLL_SCR_DTLS
    select
        nullif(trim(scrutiny_no),'') as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        nullif(trim(quotation_no),'') as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        inserted_by as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        record_date as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        0 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
    where (coalesce(nullif(trim(quotation_no),''), nullif(trim(scrutiny_no),''))) is not null

    union all

    -- branch 1: BA_HCP_PP_MEM_DTLS
    select
        scrutiny_no as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        appointment_code as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        status_code as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        type_of_checkup as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        checkup_amt as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        remarks as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        priority_flag as ASSESSMENT_HEADER__PRIORITY,
        app_date as ASSESSMENT_HEADER__SCHEDULED_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        1001 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where (scrutiny_no) is not null

    union all

    -- branch 2: BA_HCP_PROD_8439_CLH_LOADER
    select
        pd_scrutiny_number as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        plc_medical_test_alrdy_con as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        1002 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where (pd_scrutiny_number) is not null

    union all

    -- branch 3: BJAZ_ECARD_POL_DTLS_CONFIG
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        quote_ref as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        quote_status as QUOTE_HEADER__QUOTE_STATUS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        1003 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
    where (quote_ref) is not null

    union all

    -- branch 4: BJAZ_GRP_HLT_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        quote_sub_no as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        register_date as QUOTE_HEADER__QUOTE_DATE,
        remarks as QUOTE_HEADER__QUOTE_REMARKS,
        quote_status as QUOTE_HEADER__QUOTE_STATUS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
        start_date as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        1004 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where (quote_sub_no) is not null

    union all

    -- branch 5: BJAZ_HG_POL_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        quote_ref_no as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        quote_status as QUOTE_HEADER__QUOTE_STATUS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        1005 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where (quote_ref_no) is not null

    union all

    -- branch 6: BJAZ_HM_PRO_ASSESSMENT
    select
        assess_id as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        assessment_edate as ASSESSMENT_HEADER__COMPLETED_DATE,
        assessment_sdate as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        1006 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
    where (assess_id) is not null

    union all

    -- branch 7: BJAZ_SCR_HLTH_PORTABLE_DTLS
    select
        scrutiny_no as ASSESSMENT_BK,
        request_no as CASE_BK,
        member_identifier as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        1 as __LNK_ASSESSMENT_PARTY,
        1 as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        1007 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where (coalesce(member_identifier, request_no, scrutiny_no)) is not null

    union all

    -- branch 8: BJAZ_GRP_HLT_COVERAGE_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        nullif(trim(quote_no),'') as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
        quote_sub_no as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        2008 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_grp_hlt_coverage_dtls') }}
    where (nullif(trim(quote_no),'')) is not null

    union all

    -- branch 9: BJAZ_GRP_HLT_MEM_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(trim(reg_no),'') as POLICY_BK,
        nullif('PRODUCT:' || nullif(trim(product),''), 'PRODUCT:') as PRODUCT_BK,
        nullif(trim(quote_no),'') as QUOTE_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_CASE_PARTY,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__COMPLETED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__SCHEDULED_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REMARKS,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
        quote_sub_no as QUOTE_HEADER__QUOTE_VERSION,
        cast(null as varchar) as QUOTE_HEADER__REQUESTED_COVER_START_DATE,
        2009 as __PREC,
        hash(*) as __RID
    from {{ ref('stg_health__bjaz_grp_hlt_mem_dtls') }}
    where (coalesce(nullif('PRODUCT:' || nullif(trim(product),''), 'PRODUCT:'), nullif(trim(quote_no),''), nullif(trim(reg_no),''))) is not null

)

select
    ASSESSMENT_BK,
    CASE_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    QUOTE_BK,
    __LNK_ASSESSMENT_PARTY,
    __LNK_CASE_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_QUOTE_PRODUCT,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_STATUS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_TYPE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
    first_value(ASSESSMENT_HEADER__ASSESSOR_REFERENCE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
    first_value(ASSESSMENT_HEADER__COMPLETED_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__COMPLETED_DATE,
    first_value(ASSESSMENT_HEADER__CONDUCTED_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__CONDUCTED_DATE,
    first_value(ASSESSMENT_HEADER__COST_OF_ASSESSMENT) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    first_value(ASSESSMENT_HEADER__OUTCOME_SUMMARY) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
    first_value(ASSESSMENT_HEADER__PRIORITY) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__PRIORITY,
    first_value(ASSESSMENT_HEADER__SCHEDULED_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__SCHEDULED_DATE,
    first_value(QUOTE_HEADER__QUOTE_DATE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_DATE,
    first_value(QUOTE_HEADER__QUOTE_REMARKS) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_REMARKS,
    first_value(QUOTE_HEADER__QUOTE_STATUS) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_STATUS,
    first_value(QUOTE_HEADER__QUOTE_VERSION) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_VERSION,
    first_value(QUOTE_HEADER__REQUESTED_COVER_START_DATE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__REQUESTED_COVER_START_DATE
from merged
