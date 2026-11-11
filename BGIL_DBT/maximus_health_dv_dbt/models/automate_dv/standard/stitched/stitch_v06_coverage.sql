-- CENTRAL VIEW v06_coverage -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PREVIOUSINSURANCEDETAILS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_POLICY_AND_CLAIM_HISTORY
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PREVIOUSINSURANCEDETAILS
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_HEADER
--   SAT_ASSESSMENT_MEDICAL
--   SAT_AUG_COMMON_MONETARY_CONTEXT
--   SAT_AUG_COVERAGE_CONDITIONS
--   SAT_AUG_COVERAGE_DEFINITION
--   SAT_AUG_COVERAGE_INDEMNITY_RULE
--   SAT_AUG_COVERAGE_LIMITS
--   SAT_AUG_POLICY_COVERAGE_RISK_BENEFIT
--   SAT_AUG_PRODUCT_TERMS
--   SAT_AUG_RISK_HEALTH_WELLNESS
--   SAT_COMMON_BUSINESS_AUDIT
--   SAT_COVERAGE_CONDITIONS
--   SAT_COVERAGE_LIMITS
--   SAT_COVERAGE_SUBLIMIT_SCHEDULE
--   SAT_POLICY_CERTIFICATE
--   SAT_POLICY_PORTABILITY_MIGRATION
--   SAT_PRODUCT_DEFINITION
--   SAT_PRODUCT_TERMS
--   SAT_PROPOSAL_HEADER
--   SAT_PROPOSAL_QUESTIONNAIRE
--   SAT_PROPOSAL_UNDERWRITING
--   SAT_RISK_HEALTH_MEMBER_COVERAGE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_PARTY
--   LNK_FINTXN_POLICY
--   LNK_PARTY_LOCATION
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_COVERAGE_RISK
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PRODUCT_COVERAGE
--   LNK_PROPOSAL_PARTY
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
--   LNK_PROPOSAL_RISK_OBJECT
--   LNK_QUOTE_PRODUCT
--   LNK_QUOTE_PROPOSAL
--   LNK_RISK_OBJECT_LOCATION
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('BRE:' || nullif(trim(t0.claim_number),''), '') as ASSESSMENT_BK,
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        nullif(t0.plan_code, '') as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as QUOTE_BK,
        nullif('MEMBER:' || nullif(trim(t0.insured_member_code),''), '') as RISK_OBJECT_BK,
        cast(null as number) as __LNK_FINTXN_PARTY,
        cast(null as number) as __LNK_FINTXN_POLICY,
        cast(null as number) as __LNK_PARTY_LOCATION,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_COVERAGE_RISK,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_PRODUCT_COVERAGE,
        cast(null as number) as __LNK_PROPOSAL_PARTY,
        cast(null as number) as __LNK_PROPOSAL_POLICY,
        cast(null as number) as __LNK_PROPOSAL_PRODUCT,
        cast(null as number) as __LNK_PROPOSAL_RISK_OBJECT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PROPOSAL,
        cast(null as number) as __LNK_RISK_OBJECT_LOCATION,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_CATEGORY,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_MODE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        t0.bre_decision as ASSESSMENT_HEADER__OUTCOME_CODE,
        cast(null as varchar) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__PRIORITY,
        cast(null as varchar) as ASSESSMENT_HEADER__RECOMMENDATION,
        cast(null as varchar) as ASSESSMENT_HEADER__SUBJECT_REFERENCE,
        cast(null as varchar) as ASSESSMENT_HEADER__TRIGGER_EVENT,
        cast(null as varchar) as ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_DATE,
        cast(null as varchar) as ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_TYPE,
        cast(null as varchar) as AUG_COMMON_MONETARY_CONTEXT__SUM_INSURED_TRANSACTION_CURRENCY_CODE,
        cast(null as varchar) as AUG_COVERAGE_CONDITIONS__OPERATIVE_TIME_AT_RISK,
        t0.reinstatement_trigger as AUG_COVERAGE_CONDITIONS__REINSTATEMENT_TRIGGER_CONDITION,
        t0.critical_illness_and_accident_multiplier_applicable as AUG_COVERAGE_DEFINITION__COMBINED_CRITICAL_ILLNESS_AND_ACCIDENT_MULTIPLIER_APPLICABLE_INDICATOR,
        t0.double_sum_insured_benefit_applicable as AUG_COVERAGE_DEFINITION__DOUBLE_SUM_INSURED_BENEFIT_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__MUTUALLY_EXCLUSIVE_COVERS,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__MUTUALLY_INCLUSIVE_COVERS,
        cast(null as varchar) as AUG_COVERAGE_INDEMNITY_RULE__ALTERNATE_CLAIM_PAYMENT_OPTION,
        cast(null as varchar) as AUG_COVERAGE_INDEMNITY_RULE__CLAIM_PAYMENT_OPTION,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__INDEMNITY_PERIOD_DAYS,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__LIMIT_APPLICABILITY_BASIS,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__MAXIMUM_INDEMNITY_PERIOD_DAYS,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__POST_HOSPITALISATION_PERIOD,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__PRE_HOSPITALISATION_PERIOD,
        t0.sum_insured_reinstatement_akl as AUG_COVERAGE_LIMITS__REINSTATED_SUM_INSURED_AMOUNT,
        t0.reinstatement_count as AUG_COVERAGE_LIMITS__REINSTATEMENT_COUNT,
        t0.reinstatement_count_akl as AUG_COVERAGE_LIMITS__REINSTATEMENT_COUNT_AKL_VARIANT,
        t0.restoration_applied_flag as AUG_COVERAGE_LIMITS__RESTORATION_APPLIED_INDICATOR,
        t0.restoration_date as AUG_COVERAGE_LIMITS__RESTORATION_DATE,
        t0.restoration_required_flag as AUG_COVERAGE_LIMITS__RESTORATION_REQUIRED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BALANCE_LOAN_TERM,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_FIRST_INCEPTION_DATE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_MINIMUM_LIMIT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_OPTION_SELECTED,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__COVERAGE_STATUS,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__CO_PAYMENT_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__LIMIT_AMOUNT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__LIMIT_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_BENEFIT_AMOUNT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_LIMIT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__RESTORATION_INDICATOR,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__RESTORATION_LIMIT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__SOURCE_COVERAGE_REFERENCE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_RISK_BENEFIT__WAITING_PERIOD,
        cast(null as varchar) as AUG_PRODUCT_TERMS__MANDATORY_COVER_LIST,
        cast(null as varchar) as AUG_PRODUCT_TERMS__MAXIMUM_ENTRY_AGE_UNIT,
        cast(null as varchar) as AUG_PRODUCT_TERMS__MINIMUM_ENTRY_AGE_UNIT,
        cast(null as varchar) as AUG_RISK_HEALTH_WELLNESS__DISTANCE_RUN_KILOMETRES,
        cast(null as varchar) as AUG_RISK_HEALTH_WELLNESS__WELLNESS_DEVICE_RETURNED_INDICATOR,
        cast(null as varchar) as AUG_RISK_HEALTH_WELLNESS__WELLNESS_EVENT_NAME,
        cast(null as varchar) as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        cast(null as varchar) as COVERAGE_CONDITIONS__WAITING_PERIOD_CONDITION,
        cast(null as varchar) as COVERAGE_LIMITS__INDEMNITY_PERIOD,
        cast(null as varchar) as COVERAGE_LIMITS__LIMIT_TYPE,
        t0.reinstatement_applicable as COVERAGE_LIMITS__REINSTATEMENT_INDICATOR,
        t0.restoration_flag as COVERAGE_LIMITS__RESTORATION_INDICATOR,
        cast(null as varchar) as COVERAGE_LIMITS__SURVIVAL_PERIOD,
        cast(null as varchar) as COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as COVERAGE_SUBLIMIT_SCHEDULE__CAPPING_BASIS,
        cast(null as varchar) as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
        cast(null as varchar) as COVERAGE_SUBLIMIT_SCHEDULE__ROOM_CATEGORY_LINKAGE,
        cast(null as varchar) as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_AMOUNT,
        cast(null as varchar) as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_PERCENTAGE,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        t0.member_lapse_date as POLICY_CERTIFICATE__COVERAGE_END_DATE,
        t0.memberriskinceptiondate as POLICY_CERTIFICATE__COVERAGE_START_DATE,
        t0.employee_grade as POLICY_CERTIFICATE__MEMBER_CATEGORY,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        cast(null as varchar) as POLICY_CERTIFICATE__MEMBER_STATUS,
        t0.employee_lapse_date as POLICY_CERTIFICATE__TERMINATION_DATE,
        t0.policy_vintage_self as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        t0.other_insurance_company_name as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        cast(null as varchar) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        cast(null as varchar) as PRODUCT_DEFINITION__PRODUCT_CATEGORY,
        cast(null as varchar) as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
        cast(null as varchar) as PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME,
        t0.plan_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        cast(null as varchar) as PRODUCT_DEFINITION__PRODUCT_TYPE,
        cast(null as varchar) as PRODUCT_TERMS__MAXIMUM_ENTRY_AGE,
        cast(null as varchar) as PRODUCT_TERMS__MINIMUM_ENTRY_AGE,
        cast(null as varchar) as PROPOSAL_HEADER__COMPLETENESS_INDICATOR,
        cast(null as varchar) as PROPOSAL_HEADER__DECLINE_REASON,
        cast(null as varchar) as PROPOSAL_HEADER__PROJECTED_PREMIUM_AMOUNT,
        cast(null as varchar) as PROPOSAL_HEADER__PROPOSAL_DATE,
        cast(null as varchar) as PROPOSAL_HEADER__PROPOSAL_MODE,
        cast(null as varchar) as PROPOSAL_HEADER__REQUESTED_SUM_INSURED,
        cast(null as varchar) as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
        cast(null as varchar) as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        cast(null as varchar) as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE,
        cast(null as varchar) as PROPOSAL_QUESTIONNAIRE__QUESTION_TEXT,
        cast(null as varchar) as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        cast(null as varchar) as PROPOSAL_UNDERWRITING__REFERRAL_INDICATOR,
        cast(null as varchar) as PROPOSAL_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as PROPOSAL_UNDERWRITING__UNDERWRITING_STATUS,
        cast(null as varchar) as RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK,
        cast(null as varchar) as RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_AMOUNT,
        cast(null as varchar) as RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_PERCENTAGE,
        t0.sum_insured as RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('BRE:' || nullif(trim(t0.claim_number),''), ''), nullif('COV:' || nullif(trim(t0.cover),''), ''), nullif('MEMBER:' || nullif(trim(t0.insured_member_code),''), ''), nullif(nullif(trim(j2.pol_policy_number),''), ''), nullif(t0.plan_code, ''))) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=PROCEDURE_WISE
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'PROCEDURE_WISE' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        null, null, null, null,
        t0.procedure_limit_factor as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('COV:' || nullif(trim(t0.cover),''), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=ROOM_RENT
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'ROOM_RENT' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        null, null,
        t0.room_rent_limit_group as COVERAGE_SUBLIMIT_SCHEDULE__ROOM_CATEGORY_LINKAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('COV:' || nullif(trim(t0.cover),''), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null, null, null, null,
        nullif(t0.product_code, '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.product_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        t0.product_types as PRODUCT_DEFINITION__PRODUCT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.product_code, '')) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PREVIOUSINSURANCEDETAILS_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.cumulative_bonus_in_previous_policy as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        t0.continuity_indicator_approved as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        t0.insurer as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        null,
        t0.sum_insured_in_previous_policy as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_previousinsurancedtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_previousinsurancedtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.pol_policy_number),''), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(t0.policy_number, '') as POLICY_BK,
        nullif(t0.product_code, '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.source as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.product_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_policy_claim_history_msa_pv') }} t0
    where (coalesce(nullif(t0.policy_number, ''), nullif(t0.product_code, ''))) is not null

    union all

    -- branch 6: MAXI_HLTH_UWR_VW_DATA
    select
        null, null, null, null, null, null, null,
        nullif(t0.product_code, '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.product_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr') }} t0
    where (nullif(t0.product_code, '')) is not null

    union all

    -- branch 7: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        nullif(nullif(trim(j4.product_code),''), '') as PRODUCT_BK,
        nullif(nullif(trim(j4.proposal_number),''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.cumulative_bonus_in_previous_policy as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        t0.continuity_indicator_approved as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        t0.insurer as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        t0.previous_policyproposal_number as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        t0.sum_insured_in_previous_policy as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        null, null,
        t0.plan_of_policy as PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.remarks as PROPOSAL_UNDERWRITING__UNDERWRITING_REMARKS,
        null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.policy_number),''), ''), nullif(nullif(trim(j4.product_code),''), ''), nullif(nullif(trim(j4.proposal_number),''), ''))) is not null

    union all

    -- branch 8: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=OTHERS_SPECIFY
    select
        null, null, null, null, null, null, null, null,
        nullif(nullif(trim(j4.proposal_number),''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'OTHERS_SPECIFY' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        null, null,
        t0.if_others_please_specify as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.proposal_number),''), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise('MEDICAL-UW#' || nullif(trim(j2.proposal_number),''))), '') as ASSESSMENT_BK,
        null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        nullif(t0.product, '') as PRODUCT_BK,
        nullif(nullif(trim(j2.proposal_number),''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.medical_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null, null, null, null, null, null, null,
        t0.medical_type as ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.portability_renewal as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        null, null, null,
        t0.cross_sale_plan_category as PRODUCT_DEFINITION__PRODUCT_CATEGORY,
        null, null, null, null, null, null,
        t0.finalize_flag as PROPOSAL_HEADER__COMPLETENESS_INDICATOR,
        null,
        t0.quotation_amount_without_gst as PROPOSAL_HEADER__PROJECTED_PREMIUM_AMOUNT,
        null, null, null, null, null, null, null, null, null,
        t0.relaxation_remarks as PROPOSAL_UNDERWRITING__UNDERWRITING_REMARKS,
        null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise('MEDICAL-UW#' || nullif(trim(j2.proposal_number),''))), ''), nullif(nullif(trim(j2.policy_number),''), ''), nullif(nullif(trim(j2.proposal_number),''), ''), nullif(t0.product, ''))) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), '') as ASSESSMENT_BK,
        null, null, null, null, null, null,
        nullif(nullif(trim(j2.product_code),''), '') as PRODUCT_BK,
        nullif(coalesce( nullif(trim(t0.proposal_ref_no),'') , nullif(trim(j2.proposal_number),'') ), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.mediusapplication_id as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
        t0.mediusapplication_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null,
        t0.mediusremarks as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.plan as PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME,
        t0.product as PRODUCT_DEFINITION__PRODUCT_NAME,
        t0.plan_type as PRODUCT_DEFINITION__PRODUCT_TYPE,
        t0.max_age as PRODUCT_TERMS__MAXIMUM_ENTRY_AGE,
        t0.min_age as PRODUCT_TERMS__MINIMUM_ENTRY_AGE,
        null,
        t0.proposal_rejection_reason as PROPOSAL_HEADER__DECLINE_REASON,
        null,
        t0.proposal_creation_date as PROPOSAL_HEADER__PROPOSAL_DATE,
        t0.type_of_proposal as PROPOSAL_HEADER__PROPOSAL_MODE,
        null,
        t0.source_of_proposal as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
        null, null, null, null,
        t0.refer_to_underwriter as PROPOSAL_UNDERWRITING__REFERRAL_INDICATOR,
        null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), ''), nullif(coalesce( nullif(trim(t0.proposal_ref_no),'') , nullif(trim(j2.proposal_number),'') ), ''), nullif(nullif(trim(j2.product_code),''), ''))) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('UWR-ASSESSMENT:' || nullif(trim(j2.proposal_number),''), '') as ASSESSMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.underwriter_role as ASSESSMENT_HEADER__ASSESSOR_TYPE,
        null, null, null, null,
        t0.non_disclosure_uw_action as ASSESSMENT_HEADER__RECOMMENDATION,
        null,
        t0.non_disclosure_source as ASSESSMENT_HEADER__TRIGGER_EVENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('UWR-ASSESSMENT:' || nullif(trim(j2.proposal_number),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null,
        nullif('FINTXN:COVER-PREMIUM:' || ('COV:' || coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ) || ':' || coalesce(t0.member_code,'') || ':' || coalesce(t0.cover_code,'')), '') as FINANCIAL_TRANSACTION_BK,
        nullif('LOC:MEMBER_RESIDENTIAL:' || md5(normalise(nullif(trim(coalesce(t0.complete_homeresidential_address,'') || '|' || coalesce(t0.pin_code,'')), '|'))), '') as LOCATION_BK,
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        nullif(t0.plan_code, '') as PRODUCT_BK,
        nullif(nullif(trim(j4.proposal_number),''), '') as PROPOSAL_BK,
        null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        1 as __LNK_FINTXN_PARTY,
        1 as __LNK_FINTXN_POLICY,
        1 as __LNK_PARTY_LOCATION,
        null,
        1 as __LNK_POLICY_COVERAGE,
        1 as __LNK_POLICY_COVERAGE_RISK,
        1 as __LNK_POLICY_LOCATION,
        1 as __LNK_POLICY_PARTY,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        1 as __LNK_PRODUCT_COVERAGE,
        1 as __LNK_PROPOSAL_PARTY,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        null, null,
        1 as __LNK_RISK_OBJECT_LOCATION,
        1 as __LNK_RISK_OBJECT_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_level_transaction_currency_for_sum_insured as AUG_COMMON_MONETARY_CONTEXT__SUM_INSURED_TRANSACTION_CURRENCY_CODE,
        t0.operative_time_at_risk as AUG_COVERAGE_CONDITIONS__OPERATIVE_TIME_AT_RISK,
        null, null, null,
        t0.mutually_exclusive_covers as AUG_COVERAGE_DEFINITION__MUTUALLY_EXCLUSIVE_COVERS,
        t0.mutually_inclusive_covers as AUG_COVERAGE_DEFINITION__MUTUALLY_INCLUSIVE_COVERS,
        t0.claim_payment_option2 as AUG_COVERAGE_INDEMNITY_RULE__ALTERNATE_CLAIM_PAYMENT_OPTION,
        t0.claim_payment_option as AUG_COVERAGE_INDEMNITY_RULE__CLAIM_PAYMENT_OPTION,
        t0.no_of_days as AUG_COVERAGE_LIMITS__INDEMNITY_PERIOD_DAYS,
        t0.limit_applicability_for_sir as AUG_COVERAGE_LIMITS__LIMIT_APPLICABILITY_BASIS,
        t0.max_no_of_days as AUG_COVERAGE_LIMITS__MAXIMUM_INDEMNITY_PERIOD_DAYS,
        t0.posthospitalization_period_6035 as AUG_COVERAGE_LIMITS__POST_HOSPITALISATION_PERIOD,
        t0.prehospitalization_period_6035 as AUG_COVERAGE_LIMITS__PRE_HOSPITALISATION_PERIOD,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.mandatorycoverlist as AUG_PRODUCT_TERMS__MANDATORY_COVER_LIST,
        t0.maximum_age_unit as AUG_PRODUCT_TERMS__MAXIMUM_ENTRY_AGE_UNIT,
        t0.minimum_age_unit as AUG_PRODUCT_TERMS__MINIMUM_ENTRY_AGE_UNIT,
        null,
        t0.smart_watch_returned_by_customer as AUG_RISK_HEALTH_WELLNESS__WELLNESS_DEVICE_RETURNED_INDICATOR,
        null,
        t0.data_source as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        t0.critical_illness_waiting_period as COVERAGE_CONDITIONS__WAITING_PERIOD_CONDITION,
        t0.no_of_week as COVERAGE_LIMITS__INDEMNITY_PERIOD,
        t0.cover_limit_type as COVERAGE_LIMITS__LIMIT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.plan_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        t0.plan_type as PRODUCT_DEFINITION__PRODUCT_TYPE,
        t0.maximum_age as PRODUCT_TERMS__MAXIMUM_ENTRY_AGE,
        t0.minimum_age as PRODUCT_TERMS__MINIMUM_ENTRY_AGE,
        null, null, null, null,
        t0.type_of_proposal as PROPOSAL_HEADER__PROPOSAL_MODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('FINTXN:COVER-PREMIUM:' || ('COV:' || coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ) || ':' || coalesce(t0.member_code,'') || ':' || coalesce(t0.cover_code,'')), ''), nullif('LOC:MEMBER_RESIDENTIAL:' || md5(normalise(nullif(trim(coalesce(t0.complete_homeresidential_address,'') || '|' || coalesce(t0.pin_code,'')), '|'))), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''), nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(nullif(trim(j4.proposal_number),''), ''), nullif(t0.plan_code, ''))) is not null

    union all

    -- branch 13: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=ACCD
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACCD' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.accd_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 14: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=ACCH
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACCH' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.acch_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=ACCIDENTAL_COVERPLAN
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACCIDENTAL_COVERPLAN' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null,
        t0.accidental_coverplans as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_OPTION_SELECTED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 16: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=ACCIDENTAL_DEATH
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACCIDENTAL_DEATH' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.accidental_death_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 17: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=AIR_AMBULANCE_COVER
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AIR_AMBULANCE_COVER' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.air_ambulance_cover_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 18: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_code as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        t0.balance_loan_term as AUG_POLICY_COVERAGE_RISK_BENEFIT__BALANCE_LOAN_TERM,
        t0.cover_applicability as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_APPLICABLE_INDICATOR,
        null, null,
        t0.maximum_cover_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT,
        t0.road_ambulance_limit_min as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_MINIMUM_LIMIT,
        null,
        t0.applicable_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null,
        t0.with_copay as AUG_POLICY_COVERAGE_RISK_BENEFIT__CO_PAYMENT_APPLICABLE_INDICATOR,
        t0.global_copay_percentage as AUG_POLICY_COVERAGE_RISK_BENEFIT__CO_PAYMENT_PERCENTAGE,
        null,
        t0.cover_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__LIMIT_AMOUNT,
        t0.cover_limit_percentage as AUG_POLICY_COVERAGE_RISK_BENEFIT__LIMIT_PERCENTAGE,
        t0.per_day_benefit as AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_BENEFIT_AMOUNT,
        t0.per_day_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_LIMIT,
        null, null,
        t0.policyriskcoverid as AUG_POLICY_COVERAGE_RISK_BENEFIT__SOURCE_COVERAGE_REFERENCE,
        t0.time_deductible as AUG_POLICY_COVERAGE_RISK_BENEFIT__WAITING_PERIOD,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=BASIC
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.basic_sum_insured_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 20: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=CHILD_CARE_BENEFIT
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CHILD_CARE_BENEFIT' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.child_care_benefit_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 21: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=COMA_CARE
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMA_CARE' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.coma_care_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 22: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=COMPREHENSIVE
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMPREHENSIVE' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.comprehensive_sum_insured_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 23: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=CRITICAL_ILLNESS_COVERPLAN
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CRITICAL_ILLNESS_COVERPLAN' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null,
        t0.critical_illness_coverplans as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_OPTION_SELECTED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=CRITICAL_ILLNESS
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CRITICAL_ILLNESS' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.critical_illness_si as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=DOUBLE_ICU_BENEFIT
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOUBLE_ICU_BENEFIT' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null,
        t0.double_icu_benefit_applicability as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_APPLICABLE_INDICATOR,
        null, null,
        t0.double_icu_benefit_extension_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 26: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=FUNERAL_EXPENSES
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FUNERAL_EXPENSES' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null,
        t0.funeral_expenses_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT,
        null, null,
        t0.funeral_expenses_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 27: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=HPR_BENEFITS
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'HPR_BENEFITS' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null,
        t0.hpr_benefits_option as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_OPTION_SELECTED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 28: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=INSTA_SHIELD
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INSTA_SHIELD' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null,
        t0.insta_shield_first_inception_date as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_FIRST_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 29: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=LIDC
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LIDC' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null,
        t0.lidc_coverage as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_APPLICABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 30: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=LIFESTYLE_MODIFICATION_BENEFIT
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LIFESTYLE_MODIFICATION_BENEFIT' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null,
        t0.lifestyle_modification_benefit_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT,
        null, null,
        t0.lifestyle_modification_benefit_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 31: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=ONE_DAY_DEDUCTIBLE
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ONE_DAY_DEDUCTIBLE' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null,
        t0.one_day_deductible_applicability as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_APPLICABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 32: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=OPTIONAL_PLAN
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'OPTIONAL_PLAN' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null,
        t0.optional_plan as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_OPTION_SELECTED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 33: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=PERMANENT_PARTIAL_DISABILITY
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PERMANENT_PARTIAL_DISABILITY' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.permanent_partial_disability_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 34: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=PERMANENT_TOTAL_DISABILITY
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PERMANENT_TOTAL_DISABILITY' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.permanent_total_disability_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 35: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_code || '@' || 'SHCB' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.per_day_benefit_shcb as AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_BENEFIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 36: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_code || '@' || 'PER_WEEK' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null,
        t0.per_week_si as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 37: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=RESPECT_RIDER
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RESPECT_RIDER' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null,
        t0.respect_rider_plan as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_OPTION_SELECTED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 38: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=DEATH
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DEATH' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.si_for_death_cover as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 39: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=TRANSPORTATION_OF_MORTAL_REMAINS
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TRANSPORTATION_OF_MORTAL_REMAINS' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null,
        t0.transportation_of_mortal_remains_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT,
        null, null,
        t0.transportation_of_mortal_remains_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 40: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=WIDER
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WIDER' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.wider_sum_insured_limit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 41: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif('UWR-MEDICAL:' || nullif(trim(coalesce(nullif(trim(j5.proposal_number),''),'') || '#' || coalesce(t0.member_code,'')), '#'), '') as ASSESSMENT_BK,
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        nullif(nullif(trim(j5.product_code),''), '') as PRODUCT_BK,
        nullif(nullif(trim(j5.proposal_number),''), '') as PROPOSAL_BK,
        null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.date_fit as ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.no_of_km_run as AUG_RISK_HEALTH_WELLNESS__DISTANCE_RUN_KILOMETRES,
        null,
        t0.name_of_marathon as AUG_RISK_HEALTH_WELLNESS__WELLNESS_EVENT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.net_premium as POLICY_CERTIFICATE__MEMBER_PREMIUM,
        null, null, null,
        t0.cumulative_bonus_in_previous_policy as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        t0.continuity_indicator_approved as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
        t0.insurer as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
        t0.previous_policyproposal_number as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
        t0.sum_insured_in_previous_policy as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
        null, null,
        t0.plan_of_policy as PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME,
        t0.product_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        null, null, null, null, null, null, null, null, null, null,
        t0.question_id as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        t0.question_id as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE,
        t0.question_text as PROPOSAL_QUESTIONNAIRE__QUESTION_TEXT,
        null, null,
        t0.remarks as PROPOSAL_UNDERWRITING__UNDERWRITING_REMARKS,
        null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK,
        null, null,
        t0.proposed_sum_insured as RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j4.KEY_HASH
    where (coalesce(nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif('UWR-MEDICAL:' || nullif(trim(coalesce(nullif(trim(j5.proposal_number),''),'') || '#' || coalesce(t0.member_code,'')), '#'), ''), nullif(nullif(trim(j5.policy_number),''), ''), nullif(nullif(trim(j5.product_code),''), ''), nullif(nullif(trim(j5.proposal_number),''), ''))) is not null

    union all

    -- branch 42: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=OTHERS_SPECIFY
    select
        null, null, null, null, null, null, null, null,
        nullif(nullif(trim(j5.proposal_number),''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'OTHERS_SPECIFY' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        null, null,
        t0.if_others_please_specify as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.proposal_number),''), '')) is not null

    union all

    -- branch 43: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=MEDIUS_MEDICAL
    select
        null, null, null, null, null, null, null, null,
        nullif(nullif(trim(j5.proposal_number),''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'MEDIUS_MEDICAL' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        null, null,
        t0.medius_answer as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.proposal_number),''), '')) is not null

    union all

    -- branch 44: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), '') as ASSESSMENT_BK,
        nullif('COV:' || 'CLAIM_MULTIPLIER', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        nullif(t0.product_code, '') as PRODUCT_BK,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        nullif(t0.calculator_urn_number, '') as QUOTE_BK,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null,
        1 as __LNK_PROPOSAL_PRODUCT,
        null,
        1 as __LNK_QUOTE_PRODUCT,
        1 as __LNK_QUOTE_PROPOSAL,
        null, null, null, null, null,
        t0.medical_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        t0.underwriter_role as ASSESSMENT_HEADER__ASSESSOR_TYPE,
        null, null, null, null, null, null, null, null,
        t0.medical_type as ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_multiplier_applied as AUG_POLICY_COVERAGE_RISK_BENEFIT__RESTORATION_INDICATOR,
        t0.claim_multiplier_amt as AUG_POLICY_COVERAGE_RISK_BENEFIT__RESTORATION_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_plan as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
        t0.plan as PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME,
        null,
        t0.sub_plan_type as PRODUCT_DEFINITION__PRODUCT_TYPE,
        null, null, null, null, null, null, null,
        t0.proposed_sums as PROPOSAL_HEADER__REQUESTED_SUM_INSURED,
        null, null, null, null, null, null, null,
        t0.member_medius_status as PROPOSAL_UNDERWRITING__UNDERWRITING_STATUS,
        null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'CLAIM_MULTIPLIER', ''), nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''), nullif(nullif(trim(j3.proposal_number),''), ''), nullif(t0.calculator_urn_number, ''), nullif(t0.product_code, ''))) is not null

    union all

    -- branch 45: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        nullif('PPC:' || nullif(trim(coalesce(t0.ppc_reference_policyquote_number,'') || '#' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),'')), '#'), '') as ASSESSMENT_BK,
        nullif('COV:' || 'DEDUCTIBLE', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.ppc_category as ASSESSMENT_HEADER__ASSESSMENT_CATEGORY,
        t0.ppc_done_by_self_arrangement as ASSESSMENT_HEADER__ASSESSMENT_MODE,
        null,
        t0.ppc_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null,
        t0.ppc_expense as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        null, null,
        t0.ppc_priority as ASSESSMENT_HEADER__PRIORITY,
        null,
        t0.ppc_reference_policyquote_number as ASSESSMENT_HEADER__SUBJECT_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.deductible as AUG_POLICY_COVERAGE_RISK_BENEFIT__DEDUCTIBLE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || 'DEDUCTIBLE', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif('PPC:' || nullif(trim(coalesce(t0.ppc_reference_policyquote_number,'') || '#' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),'')), '#'), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 46: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=BASIC
    select
        null,
        nullif('COV:' || 'BASIC', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.basic_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'BASIC', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 47: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=COMPREHENSIVE
    select
        null,
        nullif('COV:' || 'COMPREHENSIVE', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMPREHENSIVE' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.comprehensive_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'COMPREHENSIVE', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 48: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=ENHANCED
    select
        null,
        nullif('COV:' || 'ENHANCED', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ENHANCED' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.enhanced_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'ENHANCED', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 49: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=INTERNATIONAL
    select
        null,
        nullif('COV:' || 'INTERNATIONAL', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INTERNATIONAL' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.international_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'INTERNATIONAL', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 50: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=INTERNATIONAL_ENHANCED
    select
        null,
        nullif('COV:' || 'INTERNATIONAL_ENHANCED', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INTERNATIONAL_ENHANCED' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.international_enhanced_sum_insured as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'INTERNATIONAL_ENHANCED', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 51: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=DOUBLE_SUM_INSURED
    select
        null,
        nullif('COV:' || 'DOUBLE_SUM_INSURED', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOUBLE_SUM_INSURED' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null, null, null, null, null, null,
        t0.double_sum_insured_benefit as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'DOUBLE_SUM_INSURED', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 52: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=BASIC
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null,
        t0.basic_cumulative_bonus as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CUMULATIVE_BONUS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 53: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=COMPREHENSIVE
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMPREHENSIVE' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null,
        t0.comprehensive_cumulative_bonus as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CUMULATIVE_BONUS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 54: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_POLICY_COVERAGE_RISK_BENEFIT.Benefit Code=DEATH_COVER
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DEATH_COVER' as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
        null, null,
        t0.death_cover_cumulative_bonus as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CUMULATIVE_BONUS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 55: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif('COV:' || 'INSTA_SHIELD', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.insta_shield_status as AUG_POLICY_COVERAGE_RISK_BENEFIT__COVERAGE_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'INSTA_SHIELD', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 56: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        'COV:' || 'CRITICAL_ILLNESS' as COVERAGE_BK,
        nullif('AZPARTNER:' || nullif(trim(t0.az_partner_id),''), '') as DISTRIBUTION_CHANNEL_BK,
        null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        nullif(t0.product_code, '') as PRODUCT_BK,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null,
        1 as __LNK_POLICY_CHANNEL,
        null, null, null, null,
        1 as __LNK_POLICY_PRODUCT,
        null, null, null,
        1 as __LNK_PROPOSAL_POLICY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.critical_illness_waiting_period as COVERAGE_CONDITIONS__WAITING_PERIOD_CONDITION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.member_status as POLICY_CERTIFICATE__MEMBER_STATUS,
        null, null,
        t0.external_cumulative_bonus as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK,
        t0.cumulative_bonus_earned_rs as RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_AMOUNT,
        t0.cumulative_bonus as RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_PERCENTAGE,
        coalesce(t0.applicable_sum_insured, t0.sum_insured) as RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce('COV:' || 'CRITICAL_ILLNESS', nullif('AZPARTNER:' || nullif(trim(t0.az_partner_id),''), ''), nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), ''), nullif(nullif(trim(j3.policy_number),''), ''), nullif(nullif(trim(j3.proposal_number),''), ''), nullif(t0.product_code, ''))) is not null

    union all

    -- branch 57: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sum_insured_reinstatement_applicable as COVERAGE_LIMITS__REINSTATEMENT_INDICATOR,
        null,
        t0.survival_period_duration as COVERAGE_LIMITS__SURVIVAL_PERIOD,
        t0.voluntary_aggregate_deductible as COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT,
        null, null,
        t0.self_room_rent as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
        null,
        coalesce(t0.self_posthospitalization_expenses, t0.self_prehospitalization_expenses) as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 58: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=PER_DAY_BENEFIT
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'PER_DAY_BENEFIT' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        null,
        t0.per_day_benefit as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 59: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=POST_HOSPITALIZATION
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'POST_HOSPITALIZATION' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        null, null, null,
        t0.posthospitalization_expenses as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 60: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=PRE_HOSPITALIZATION
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'PRE_HOSPITALIZATION' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        null, null, null,
        t0.prehospitalization_expenses as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 61: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=PROCEDURE_WISE
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'PROCEDURE_WISE' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        null, null, null,
        t0.procedure_wise_sub_limit as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 62: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=ROOM_RENT
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'ROOM_RENT' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.room_rent_capping as COVERAGE_SUBLIMIT_SCHEDULE__CAPPING_BASIS,
        t0.room_rent as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 63: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=ROOM_RENT_ICU
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'ROOM_RENT_ICU' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        null,
        t0.room_rent_icu as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 64: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=ROOM_RENT_NORMAL
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'ROOM_RENT_NORMAL' as COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        null,
        t0.room_rent_normal as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 65: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): PROPOSAL_QUESTIONNAIRE.Question Code=MEDIUS_QUESTIONS
    select
        null, null, null, null, null, null, null, null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'MEDIUS_QUESTIONS' as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
        null, null,
        t0.mediusquestions as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.proposal_number),''), '')) is not null

    union all

    -- branch 66: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif('COV:' || 'BASIC', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'BASIC', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 67: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif('COV:' || 'COMPREHENSIVE', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'COMPREHENSIVE', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 68: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif('COV:' || 'ENHANCED', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'ENHANCED', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 69: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif('COV:' || 'INTERNATIONAL', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'INTERNATIONAL', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 70: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif('COV:' || 'INTERNATIONAL_ENHANCED', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'INTERNATIONAL_ENHANCED', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 71: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif('COV:' || 'DOUBLE_SUM_INSURED', '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('COV:' || 'DOUBLE_SUM_INSURED', ''), nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 72: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null,
        nullif(nullif('COV:' || coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),''), 'COV:##'), '') as COVERAGE_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE_RISK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif('COV:' || coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),''), 'COV:##'), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 73: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_POLICY_AND_CLAIM_HISTORY
    select
        null, null, null, null, null, null,
        nullif(t0.policy_number, '') as POLICY_BK,
        nullif(t0.product_code, '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.source as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.product_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_memd_tabs_policy_and_claim_history') }} t0
    where (coalesce(nullif(t0.policy_number, ''), nullif(t0.product_code, ''))) is not null

)

select
    ASSESSMENT_BK,
    COVERAGE_BK,
    DISTRIBUTION_CHANNEL_BK,
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    QUOTE_BK,
    RISK_OBJECT_BK,
    __LNK_FINTXN_PARTY,
    __LNK_FINTXN_POLICY,
    __LNK_PARTY_LOCATION,
    __LNK_POLICY_CHANNEL,
    __LNK_POLICY_COVERAGE,
    __LNK_POLICY_COVERAGE_RISK,
    __LNK_POLICY_LOCATION,
    __LNK_POLICY_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_PRODUCT_COVERAGE,
    __LNK_PROPOSAL_PARTY,
    __LNK_PROPOSAL_POLICY,
    __LNK_PROPOSAL_PRODUCT,
    __LNK_PROPOSAL_RISK_OBJECT,
    __LNK_QUOTE_PRODUCT,
    __LNK_QUOTE_PROPOSAL,
    __LNK_RISK_OBJECT_LOCATION,
    __LNK_RISK_OBJECT_PARTY,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_CATEGORY) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_CATEGORY,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_MODE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_MODE,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_STATUS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    first_value(ASSESSMENT_HEADER__ASSESSOR_TYPE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSOR_TYPE,
    first_value(ASSESSMENT_HEADER__COST_OF_ASSESSMENT) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    first_value(ASSESSMENT_HEADER__OUTCOME_CODE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__OUTCOME_CODE,
    first_value(ASSESSMENT_HEADER__OUTCOME_SUMMARY) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__OUTCOME_SUMMARY,
    first_value(ASSESSMENT_HEADER__PRIORITY) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__PRIORITY,
    first_value(ASSESSMENT_HEADER__RECOMMENDATION) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__RECOMMENDATION,
    first_value(ASSESSMENT_HEADER__SUBJECT_REFERENCE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__SUBJECT_REFERENCE,
    first_value(ASSESSMENT_HEADER__TRIGGER_EVENT) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__TRIGGER_EVENT,
    first_value(ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_DATE,
    first_value(ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_TYPE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_TYPE,
    first_value(AUG_COMMON_MONETARY_CONTEXT__SUM_INSURED_TRANSACTION_CURRENCY_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_MONETARY_CONTEXT__SUM_INSURED_TRANSACTION_CURRENCY_CODE,
    first_value(AUG_COVERAGE_CONDITIONS__OPERATIVE_TIME_AT_RISK) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_CONDITIONS__OPERATIVE_TIME_AT_RISK,
    first_value(AUG_COVERAGE_CONDITIONS__REINSTATEMENT_TRIGGER_CONDITION) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_CONDITIONS__REINSTATEMENT_TRIGGER_CONDITION,
    first_value(AUG_COVERAGE_DEFINITION__COMBINED_CRITICAL_ILLNESS_AND_ACCIDENT_MULTIPLIER_APPLICABLE_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__COMBINED_CRITICAL_ILLNESS_AND_ACCIDENT_MULTIPLIER_APPLICABLE_INDICATOR,
    first_value(AUG_COVERAGE_DEFINITION__DOUBLE_SUM_INSURED_BENEFIT_APPLICABLE_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__DOUBLE_SUM_INSURED_BENEFIT_APPLICABLE_INDICATOR,
    first_value(AUG_COVERAGE_DEFINITION__MUTUALLY_EXCLUSIVE_COVERS) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__MUTUALLY_EXCLUSIVE_COVERS,
    first_value(AUG_COVERAGE_DEFINITION__MUTUALLY_INCLUSIVE_COVERS) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__MUTUALLY_INCLUSIVE_COVERS,
    first_value(AUG_COVERAGE_INDEMNITY_RULE__ALTERNATE_CLAIM_PAYMENT_OPTION) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_INDEMNITY_RULE__ALTERNATE_CLAIM_PAYMENT_OPTION,
    first_value(AUG_COVERAGE_INDEMNITY_RULE__CLAIM_PAYMENT_OPTION) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_INDEMNITY_RULE__CLAIM_PAYMENT_OPTION,
    first_value(AUG_COVERAGE_LIMITS__INDEMNITY_PERIOD_DAYS) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__INDEMNITY_PERIOD_DAYS,
    first_value(AUG_COVERAGE_LIMITS__LIMIT_APPLICABILITY_BASIS) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__LIMIT_APPLICABILITY_BASIS,
    first_value(AUG_COVERAGE_LIMITS__MAXIMUM_INDEMNITY_PERIOD_DAYS) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__MAXIMUM_INDEMNITY_PERIOD_DAYS,
    first_value(AUG_COVERAGE_LIMITS__POST_HOSPITALISATION_PERIOD) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__POST_HOSPITALISATION_PERIOD,
    first_value(AUG_COVERAGE_LIMITS__PRE_HOSPITALISATION_PERIOD) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__PRE_HOSPITALISATION_PERIOD,
    first_value(AUG_COVERAGE_LIMITS__REINSTATED_SUM_INSURED_AMOUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__REINSTATED_SUM_INSURED_AMOUNT,
    first_value(AUG_COVERAGE_LIMITS__REINSTATEMENT_COUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__REINSTATEMENT_COUNT,
    first_value(AUG_COVERAGE_LIMITS__REINSTATEMENT_COUNT_AKL_VARIANT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__REINSTATEMENT_COUNT_AKL_VARIANT,
    first_value(AUG_COVERAGE_LIMITS__RESTORATION_APPLIED_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__RESTORATION_APPLIED_INDICATOR,
    first_value(AUG_COVERAGE_LIMITS__RESTORATION_DATE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__RESTORATION_DATE,
    first_value(AUG_COVERAGE_LIMITS__RESTORATION_REQUIRED_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__RESTORATION_REQUIRED_INDICATOR,
    AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__BALANCE_LOAN_TERM) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BALANCE_LOAN_TERM,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_APPLICABLE_INDICATOR) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_APPLICABLE_INDICATOR,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CUMULATIVE_BONUS_AMOUNT) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CUMULATIVE_BONUS_AMOUNT,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_FIRST_INCEPTION_DATE) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_FIRST_INCEPTION_DATE,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_LIMIT,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_MINIMUM_LIMIT) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_MINIMUM_LIMIT,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_OPTION_SELECTED) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_OPTION_SELECTED,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_SUM_INSURED,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__COVERAGE_STATUS) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__COVERAGE_STATUS,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__CO_PAYMENT_APPLICABLE_INDICATOR) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__CO_PAYMENT_APPLICABLE_INDICATOR,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__CO_PAYMENT_PERCENTAGE) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__CO_PAYMENT_PERCENTAGE,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__DEDUCTIBLE_AMOUNT) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__DEDUCTIBLE_AMOUNT,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__LIMIT_AMOUNT) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__LIMIT_AMOUNT,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__LIMIT_PERCENTAGE) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__LIMIT_PERCENTAGE,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_BENEFIT_AMOUNT) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_BENEFIT_AMOUNT,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_LIMIT) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__PER_DAY_LIMIT,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__RESTORATION_INDICATOR) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__RESTORATION_INDICATOR,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__RESTORATION_LIMIT) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__RESTORATION_LIMIT,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__SOURCE_COVERAGE_REFERENCE) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__SOURCE_COVERAGE_REFERENCE,
    first_value(AUG_POLICY_COVERAGE_RISK_BENEFIT__WAITING_PERIOD) ignore nulls over (partition by COVERAGE_BK, POLICY_BK, RISK_OBJECT_BK, AUG_POLICY_COVERAGE_RISK_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_RISK_BENEFIT__WAITING_PERIOD,
    first_value(AUG_PRODUCT_TERMS__MANDATORY_COVER_LIST) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__MANDATORY_COVER_LIST,
    first_value(AUG_PRODUCT_TERMS__MAXIMUM_ENTRY_AGE_UNIT) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__MAXIMUM_ENTRY_AGE_UNIT,
    first_value(AUG_PRODUCT_TERMS__MINIMUM_ENTRY_AGE_UNIT) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__MINIMUM_ENTRY_AGE_UNIT,
    first_value(AUG_RISK_HEALTH_WELLNESS__DISTANCE_RUN_KILOMETRES) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_HEALTH_WELLNESS__DISTANCE_RUN_KILOMETRES,
    first_value(AUG_RISK_HEALTH_WELLNESS__WELLNESS_DEVICE_RETURNED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_HEALTH_WELLNESS__WELLNESS_DEVICE_RETURNED_INDICATOR,
    first_value(AUG_RISK_HEALTH_WELLNESS__WELLNESS_EVENT_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_HEALTH_WELLNESS__WELLNESS_EVENT_NAME,
    first_value(COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
    first_value(COVERAGE_CONDITIONS__WAITING_PERIOD_CONDITION) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_CONDITIONS__WAITING_PERIOD_CONDITION,
    first_value(COVERAGE_LIMITS__INDEMNITY_PERIOD) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__INDEMNITY_PERIOD,
    first_value(COVERAGE_LIMITS__LIMIT_TYPE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__LIMIT_TYPE,
    first_value(COVERAGE_LIMITS__REINSTATEMENT_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__REINSTATEMENT_INDICATOR,
    first_value(COVERAGE_LIMITS__RESTORATION_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__RESTORATION_INDICATOR,
    first_value(COVERAGE_LIMITS__SURVIVAL_PERIOD) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__SURVIVAL_PERIOD,
    first_value(COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT,
    COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(COVERAGE_SUBLIMIT_SCHEDULE__CAPPING_BASIS) ignore nulls over (partition by COVERAGE_BK, COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_SUBLIMIT_SCHEDULE__CAPPING_BASIS,
    first_value(COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT) ignore nulls over (partition by COVERAGE_BK, COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT,
    first_value(COVERAGE_SUBLIMIT_SCHEDULE__ROOM_CATEGORY_LINKAGE) ignore nulls over (partition by COVERAGE_BK, COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_SUBLIMIT_SCHEDULE__ROOM_CATEGORY_LINKAGE,
    first_value(COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_AMOUNT) ignore nulls over (partition by COVERAGE_BK, COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_AMOUNT,
    first_value(COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_PERCENTAGE) ignore nulls over (partition by COVERAGE_BK, COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_SUBLIMIT_SCHEDULE__SUB_LIMIT_PERCENTAGE,
    POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    first_value(POLICY_CERTIFICATE__COVERAGE_END_DATE) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__COVERAGE_END_DATE,
    first_value(POLICY_CERTIFICATE__COVERAGE_START_DATE) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__COVERAGE_START_DATE,
    first_value(POLICY_CERTIFICATE__MEMBER_CATEGORY) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__MEMBER_CATEGORY,
    first_value(POLICY_CERTIFICATE__MEMBER_PREMIUM) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__MEMBER_PREMIUM,
    first_value(POLICY_CERTIFICATE__MEMBER_STATUS) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__MEMBER_STATUS,
    first_value(POLICY_CERTIFICATE__TERMINATION_DATE) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__TERMINATION_DATE,
    first_value(POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED,
    first_value(POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__CUMULATIVE_BONUS_PORTED,
    first_value(POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PORTABILITY_INDICATOR,
    first_value(POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME,
    first_value(POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER,
    first_value(POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PORTABILITY_MIGRATION__PREVIOUS_SUM_INSURED,
    first_value(PRODUCT_DEFINITION__PRODUCT_CATEGORY) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_CATEGORY,
    first_value(PRODUCT_DEFINITION__PRODUCT_DESCRIPTION) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_DESCRIPTION,
    first_value(PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_DISPLAY_NAME,
    first_value(PRODUCT_DEFINITION__PRODUCT_NAME) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_NAME,
    first_value(PRODUCT_DEFINITION__PRODUCT_TYPE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_TYPE,
    first_value(PRODUCT_TERMS__MAXIMUM_ENTRY_AGE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_TERMS__MAXIMUM_ENTRY_AGE,
    first_value(PRODUCT_TERMS__MINIMUM_ENTRY_AGE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_TERMS__MINIMUM_ENTRY_AGE,
    first_value(PROPOSAL_HEADER__COMPLETENESS_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__COMPLETENESS_INDICATOR,
    first_value(PROPOSAL_HEADER__DECLINE_REASON) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__DECLINE_REASON,
    first_value(PROPOSAL_HEADER__PROJECTED_PREMIUM_AMOUNT) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__PROJECTED_PREMIUM_AMOUNT,
    first_value(PROPOSAL_HEADER__PROPOSAL_DATE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__PROPOSAL_DATE,
    first_value(PROPOSAL_HEADER__PROPOSAL_MODE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__PROPOSAL_MODE,
    first_value(PROPOSAL_HEADER__REQUESTED_SUM_INSURED) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__REQUESTED_SUM_INSURED,
    first_value(PROPOSAL_HEADER__SUBMISSION_CHANNEL) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
    PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK,
    first_value(PROPOSAL_QUESTIONNAIRE__QUESTION_CODE) ignore nulls over (partition by PROPOSAL_BK, PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_QUESTIONNAIRE__QUESTION_CODE,
    first_value(PROPOSAL_QUESTIONNAIRE__QUESTION_TEXT) ignore nulls over (partition by PROPOSAL_BK, PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_QUESTIONNAIRE__QUESTION_TEXT,
    first_value(PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE) ignore nulls over (partition by PROPOSAL_BK, PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE,
    first_value(PROPOSAL_UNDERWRITING__REFERRAL_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_UNDERWRITING__REFERRAL_INDICATOR,
    first_value(PROPOSAL_UNDERWRITING__UNDERWRITING_REMARKS) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_UNDERWRITING__UNDERWRITING_REMARKS,
    first_value(PROPOSAL_UNDERWRITING__UNDERWRITING_STATUS) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_UNDERWRITING__UNDERWRITING_STATUS,
    RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK,
    first_value(RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_AMOUNT) ignore nulls over (partition by RISK_OBJECT_BK, RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_AMOUNT,
    first_value(RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_PERCENTAGE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_PERCENTAGE,
    first_value(RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED) ignore nulls over (partition by RISK_OBJECT_BK, RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED
from merged
