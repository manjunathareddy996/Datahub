-- CENTRAL VIEW v17_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_UNDERWRITING
--   SAT_AUG_RISK_PERSON_INSURED
--   SAT_COVERAGE_MEMBER_BENEFIT
--   SAT_POLICY_COVERAGE_SCHEDULE
--   SAT_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_POLICY_PREMIUM_HEAD
--   SAT_PROPOSAL_DECLARATIONS
--   SAT_RISK_HEALTH_MEMBER_MEDICAL
--   SAT_RISK_PERSON_INSURED
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=OTHER_CRITICAL_ILLNESS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PROPOSAL_BK,
        nullif('MEMBER:' || nullif(trim(t0.insured_member_code),''), '') as RISK_OBJECT_BK,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__ACCEPTANCE_DECISION,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__DEVIATION_JUSTIFICATION,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__REINSURANCE_REFERRAL_INDICATOR,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__RISK_GRADE,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_RISK_PERSON_INSURED__CONSENT_LETTER_REQUIRED_INDICATOR,
        cast(null as varchar) as COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE_CK,
        cast(null as varchar) as COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE,
        cast(null as varchar) as COVERAGE_MEMBER_BENEFIT__BENEFIT_NAME,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_TYPE,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__SECTION_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        cast(null as varchar) as PROPOSAL_DECLARATIONS__ADVERSE_HEALTH_DECLARATION_INDICATOR,
        cast(null as varchar) as PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR,
        cast(null as varchar) as PROPOSAL_DECLARATIONS__MEDICAL_HISTORY_DECLARATION_INDICATOR,
        cast(null as varchar) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'OTHER_CRITICAL_ILLNESS' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        t0.other_critical_illness as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME,
        cast(null as varchar) as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        cast(null as varchar) as RISK_HEALTH_MEMBER_MEDICAL__ICD_CODE,
        cast(null as varchar) as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        cast(null as varchar) as RISK_PERSON_INSURED__BODY_MASS_INDEX,
        cast(null as varchar) as RISK_PERSON_INSURED__CUMULATIVE_BONUS_APPLICABLE_INDICATOR,
        cast(null as varchar) as RISK_PERSON_INSURED__DISABILITY_INDICATOR,
        cast(null as varchar) as RISK_PERSON_INSURED__HEALTH_CARD_NUMBER,
        cast(null as varchar) as RISK_PERSON_INSURED__HEIGHT,
        cast(null as varchar) as RISK_PERSON_INSURED__OCCUPATION_CLASS_CODE,
        cast(null as varchar) as RISK_PERSON_INSURED__PERMANENT_EXCLUSION_INDICATOR,
        cast(null as varchar) as RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_INDICATOR,
        cast(null as varchar) as RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || nullif(trim(t0.insured_member_code),''), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim(t0.insured_member_code),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.health_card_number as RISK_PERSON_INSURED__HEALTH_CARD_NUMBER,
        null, null, null, null,
        t0.ped_flag as RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_INDICATOR,
        t0.patient_relation as RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || nullif(trim(t0.insured_member_code),''), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null,
        nullif('MEMBER:' || nullif(trim(t0.member_code),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.discount_loading_type as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null,
        t0.discount_loading_type as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
        null,
        t0.discount_and_loading_reason as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        t0.discount_loading_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null,
        t0.icd_code as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        t0.icd_description as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME,
        null,
        t0.icd_code as RISK_HEALTH_MEMBER_MEDICAL__ICD_CODE,
        null, null, null, null, null, null, null, null, null, null,
        t0.relationship_with_proposer as RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif('MEMBER:' || nullif(trim(t0.member_code),''), ''), nullif(nullif(trim(j4.policy_number),''), ''))) is not null

    union all

    -- branch 3: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.discount_loading_type_policy as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null,
        t0.discount_loading_type_policy as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
        null,
        t0.loading_discount_reason_policy as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 4: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null, null, null, null,
        t0.discount_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=LOADING
    select
        null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null, null, null, null,
        t0.loading_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('UWR-ASSESSMENT:' || nullif(trim(j2.proposal_number),''), '') as ASSESSMENT_BK,
        null, null,
        nullif(nullif(trim(j2.proposal_number),''), '') as PROPOSAL_BK,
        null, null,
        t0.non_disclosure_uwr_decision as ASSESSMENT_UNDERWRITING__ACCEPTANCE_DECISION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.positive_health_declaration as PROPOSAL_DECLARATIONS__ADVERSE_HEALTH_DECLARATION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('UWR-ASSESSMENT:' || nullif(trim(j2.proposal_number),''), ''), nullif(nullif(trim(j2.proposal_number),''), ''))) is not null

    union all

    -- branch 7: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=CONSUMABLES, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CONSUMABLES' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null,
        t0.consumables as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=POLICY_TERM, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICY_TERM' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        t0.period_to_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null, null, null,
        t0.period_from_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=POST_HOSPITALIZATION, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POST_HOSPITALIZATION' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null, null, null, null, null, null,
        t0.posthospitalization_expenses as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PRE_HOSPITALIZATION, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PRE_HOSPITALIZATION' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null, null, null, null, null, null,
        t0.prehospitalization_expenses as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=PROCEDURE_WISE, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROCEDURE_WISE' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null, null, null, null, null, null,
        t0.procedure_wise_sub_limit as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=ROOM_RENT, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ROOM_RENT' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null, null, null, null, null, null,
        t0.room_rent as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=ROOM_RENT_ICU, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ROOM_RENT_ICU' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null, null, null, null, null, null,
        t0.room_rent_icu as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=SURGERY_ONLY, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SURGERY_ONLY' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null,
        t0.surgery_only_cover as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=CASHLESS_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CASHLESS_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.cashless_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 16: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=DISCOUNT_AND_LOADING
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DISCOUNT_AND_LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.discount_and_loading as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 17: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=DISCOUNT_FACTOR
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DISCOUNT_FACTOR' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null,
        t0.discount_factor_details as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 18: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=EMPLOYEE_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.employee_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=LOYALTY_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOYALTY_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.loyalty_discount_applicable as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 20: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=NO_CLAIM_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NO_CLAIM_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.no_claim_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 21: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=ONLINE_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ONLINE_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.online_discount_applicable as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=WELLNESS_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WELLNESS_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.wellness_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 23: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS
    select
        null,
        nullif('COV:' || nullif(trim(t0.benefit_code),''), '') as COVERAGE_BK,
        nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '') as POLICY_BK,
        null, null,
        1 as __LNK_POLICY_COVERAGE,
        null, null, null, null, null, null, null, null,
        t0.benefit_code as COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE_CK,
        t0.benefit_code as COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE,
        t0.benefit_name as COVERAGE_MEMBER_BENEFIT__BENEFIT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits') }} t0
    left join {{ ref('stg_mxh__uwr_members') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.benefit_code),''), ''), nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), ''))) is not null

    union all

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.benefit_code as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        t0.expiry_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null, null, null,
        t0.inception_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits') }} t0
    left join {{ ref('stg_mxh__uwr_members') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '')) is not null

    union all

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS | child-key literal(s): POLICY_PREMIUM_HEAD.Adjusted Indicator=N, POLICY_PREMIUM_HEAD.Premium Head Code=GROSS_PREMIUM, POLICY_PREMIUM_HEAD.Section=POLICY
    select
        null, null,
        nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'GROSS_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        t0.benefit_code as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'POLICY' as POLICY_PREMIUM_HEAD__SECTION_CK,
        'N' as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        t0.gross_premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits') }} t0
    left join {{ ref('stg_mxh__uwr_members') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '')) is not null

    union all

    -- branch 26: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS | child-key literal(s): POLICY_PREMIUM_HEAD.Adjusted Indicator=N, POLICY_PREMIUM_HEAD.Premium Head Code=NET_PREMIUM, POLICY_PREMIUM_HEAD.Section=POLICY
    select
        null, null,
        nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'NET_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        t0.benefit_code as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'POLICY' as POLICY_PREMIUM_HEAD__SECTION_CK,
        'N' as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        t0.premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits') }} t0
    left join {{ ref('stg_mxh__uwr_members') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '')) is not null

    union all

    -- branch 27: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_code as COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE_CK,
        null,
        t0.cover_benefit as COVERAGE_MEMBER_BENEFIT__BENEFIT_NAME,
        t0.cover_code as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        t0.serial_no as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        t0.cover_expiry_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null, null,
        t0.serial_no as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
        t0.cover_first_effective_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        t0.cover_premium as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover_code),''), ''), nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), ''))) is not null

    union all

    -- branch 28: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=NO_CLAIM_DISCOUNT
    select
        null, null,
        nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NO_CLAIM_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.no_claim_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce( nullif(trim(j4.policy_number),'') ,'PROPOSAL:' || nullif(trim(j4.proposal_number),'') ), '')) is not null

    union all

    -- branch 29: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=ASTHMA
    select
        null, null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'ASTHMA' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.asthma_insh_cvr as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 30: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=DIABETES
    select
        null, null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'DIABETES' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.diabetes_insh_cvr as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 31: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HYPERLIPIDAEMIA
    select
        null, null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HYPERLIPIDAEMIA' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.hyperlipidaemia_insh_cvr as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 32: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HYPERTENSION
    select
        null, null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HYPERTENSION' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.hypertension_insh_cvr as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 33: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HYPOTHYROIDISM
    select
        null, null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HYPOTHYROIDISM' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.hypothyroidism_insh_cvr as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 34: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=NOTA
    select
        null, null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'NOTA' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.nota_insh_cvr as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 35: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=OBESITY
    select
        null, null, null, null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'OBESITY' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.obesity_insh_cvr as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_benefits_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_benefits') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 36: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW
    select
        nullif(md5(nullif(trim('UWR_MEDICAL_RATING#' || coalesce(t0.foreign_key,'') || '#' || coalesce(t0.parent_key_hash,'')), 'UWR_MEDICAL_RATING##')), '') as ASSESSMENT_BK,
        null, null,
        nullif(t0.foreign_key, '') as PROPOSAL_BK,
        null, null,
        t0.system_decision as ASSESSMENT_UNDERWRITING__ACCEPTANCE_DECISION,
        null, null, null, null,
        t0.termsofacceptanceandrejection as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
        t0.general_remarks as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.positivehealthdeclaration as PROPOSAL_DECLARATIONS__ADVERSE_HEALTH_DECLARATION_INDICATOR,
        null,
        t0.declare_health_history as PROPOSAL_DECLARATIONS__MEDICAL_HISTORY_DECLARATION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    where (coalesce(nullif(md5(nullif(trim('UWR_MEDICAL_RATING#' || coalesce(t0.foreign_key,'') || '#' || coalesce(t0.parent_key_hash,'')), 'UWR_MEDICAL_RATING##')), ''), nullif(t0.foreign_key, ''))) is not null

    union all

    -- branch 37: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=UNDERWRITING_LOADING
    select
        null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UNDERWRITING_LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null, null,
        t0.type_of_underwriting_loading as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_TYPE,
        t0.loading_reason as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        t0.underwriting_loading_percentage as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_decisions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_decisions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 38: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null,
        t0.col_required_rb as AUG_RISK_PERSON_INSURED__CONSENT_LETTER_REQUIRED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.applicability_rb as RISK_PERSON_INSURED__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 39: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=ARTHRITIS
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'ARTHRITIS' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.arthritis_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 40: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=ASTHMA
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'ASTHMA' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.asthma_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 41: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=CARDIOVASCULAR
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'CARDIOVASCULAR' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.cardiovascular_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 42: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=DIABETES
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'DIABETES' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.diabetes_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 43: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=ECG_DEVIATION
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'ECG_DEVIATION' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.ecg_deviation_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 44: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HYPERLIPIDAEMIA
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HYPERLIPIDAEMIA' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.hyperlipidaemia_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 45: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HYPERTENSION
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HYPERTENSION' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.hypertension_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 46: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=OBESITY
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'OBESITY' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.obesity_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 47: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=2D_ECHO
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        '2D_ECHO' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.only_2d_eco_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 48: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=OTHERS
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'OTHERS' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        t0.other_details_1 as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME,
        null, null,
        t0.others_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 49: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=THYROID
    select
        null, null, null, null,
        nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim((case when x1._N = 1 then x1._V end)),'') as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'THYROID' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null, null, null,
        t0.thyroid_rb as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_medicalrating_exclusions_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_medicalrating_exclusions') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_medicalrating') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j3.KEY_HASH
    where (nullif('MEMBER:' || nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 50: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.discount_loading_type as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null,
        t0.discount_loading_type as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
        null,
        t0.discount_and_loading_reason as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        t0.discount_loading_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        t0.icd_code as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        t0.icd_description as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME,
        null,
        t0.icd_code as RISK_HEALTH_MEMBER_MEDICAL__ICD_CODE,
        null, null, null, null, null, null, null, null, null, null,
        t0.relationship_with_proposer as RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER,
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
    where (coalesce(nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(nullif(trim(j5.policy_number),''), ''))) is not null

    union all

    -- branch 51: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.discount_loading_type_policy as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null,
        t0.discount_loading_type_policy as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
        null,
        t0.loading_discount_reason_policy as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number),''), '')) is not null

    union all

    -- branch 52: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null, null, null, null,
        t0.discount_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number),''), '')) is not null

    union all

    -- branch 53: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=LOADING
    select
        null, null,
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null, null, null, null,
        t0.loading_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number),''), '')) is not null

    union all

    -- branch 54: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), '') as ASSESSMENT_BK,
        null, null,
        nullif(nullif(trim(j3.proposal_number),''), '') as PROPOSAL_BK,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null,
        t0.relaxation_remarks as ASSESSMENT_UNDERWRITING__DEVIATION_JUSTIFICATION,
        t0.manual_underwriting_required as ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR,
        t0.reins_pending_indicator as ASSESSMENT_UNDERWRITING__REINSURANCE_REFERRAL_INDICATOR,
        t0.mediusrisk_class as ASSESSMENT_UNDERWRITING__RISK_GRADE,
        null,
        coalesce(t0.manual_underwriting_details, t0.remarks) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.do_you_have_any_existing_pa_policy_ as PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR,
        null, null, null, null, null, null, null,
        t0.mediusbmi as RISK_PERSON_INSURED__BODY_MASS_INDEX,
        t0.cb_verified as RISK_PERSON_INSURED__CUMULATIVE_BONUS_APPLICABLE_INDICATOR,
        t0.any_existing_disability as RISK_PERSON_INSURED__DISABILITY_INDICATOR,
        t0.health_card_number as RISK_PERSON_INSURED__HEALTH_CARD_NUMBER,
        t0.mediusheight_in_cms as RISK_PERSON_INSURED__HEIGHT,
        t0.type_of_occupation as RISK_PERSON_INSURED__OCCUPATION_CLASS_CODE,
        null,
        t0.ped_details as RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_DESCRIPTION,
        null,
        t0.relationship as RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER,
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
    where (coalesce(nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), ''), nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), ''), nullif(nullif(trim(j3.proposal_number),''), ''))) is not null

    union all

    -- branch 55: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null, null,
        t0.addedcovers as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 56: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=CONSUMABLES, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CONSUMABLES' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null,
        t0.consumables as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 57: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Reference=SURGERY_ONLY, POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SURGERY_ONLY' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        null,
        t0.surgery_only_cover as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 58: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=CASHLESS_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CASHLESS_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.cashless_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 59: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=COST_SHARING_LOADING
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COST_SHARING_LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.cost_sharing_loading as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 60: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=DISCOUNT_AND_LOADING
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DISCOUNT_AND_LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.discount_and_loading as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 61: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=FITNESS_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FITNESS_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.fitness_discounts as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 62: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=LOYALTY_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOYALTY_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.loyalty_discounts as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 63: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=NON_NETWORK_COPAY_WAIVER_LOADING
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_NETWORK_COPAY_WAIVER_LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.non_network_copay_waiver_loading as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 64: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=NO_CLAIM_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NO_CLAIM_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.no_claim_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 65: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=PREVENTIVE_HEALTH_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PREVENTIVE_HEALTH_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.preventive_health_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 66: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=UWR_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UWR_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.uwr_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 67: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_DISCOUNT_LOADING_APPLIED.Item Code=WELLNESS_DISCOUNT
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WELLNESS_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.wellness_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 68: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_PREMIUM_HEAD.Adjusted Indicator=N, POLICY_PREMIUM_HEAD.Coverage Reference=ALL, POLICY_PREMIUM_HEAD.Premium Head Code=BASE_PREMIUM, POLICY_PREMIUM_HEAD.Section=POLICY
    select
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'BASE_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        'ALL' as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'POLICY' as POLICY_PREMIUM_HEAD__SECTION_CK,
        'N' as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        t0.member_level_premium_before_col as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 69: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=ASTHMA
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'ASTHMA' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.asthma_insh as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 70: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=DIABETES
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'DIABETES' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.diabetes_insh as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 71: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HYPERLIPIDAEMIA
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HYPERLIPIDAEMIA' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.hyperlipidaemia_insh as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 72: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HYPERTENSION
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HYPERTENSION' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.hypertension_insh as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 73: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HYPOTHYROIDISM
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HYPOTHYROIDISM' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.hypothyroidism_insh as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 74: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=HIV_AIDS
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'HIV_AIDS' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.hivaids as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 75: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=PRE_EXISTING_DISEASE
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'PRE_EXISTING_DISEASE' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        t0.pre_existing_illness as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME,
        t0.existing_ped_flag as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 76: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=NOTA
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'NOTA' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.nota_insh as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 77: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_MEMBER_MEDICAL.Condition Code=OBESITY
    select
        null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) as RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        'OBESITY' as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        null,
        t0.obesity_insh as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
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
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 78: MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS | child-key literal(s): POLICY_COVERAGE_SCHEDULE.Coverage Sequence=1
    select
        null, null,
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover || '@' || t0.member_name as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        '1' as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        t0.period_end_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null, null, null,
        t0.period_start_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        t0.total_premium_for_acover_pre_tax as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_premium_calculation_dtls') }} t0
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.policy_number),''), '')) is not null

    union all

    -- branch 79: MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS
    select
        null, null,
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOADING_DISCOUNT' || '@' || t0.cover || '@' || t0.member_name as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.loading_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_premium_calculation_dtls') }} t0
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.policy_number),''), '')) is not null

    union all

    -- branch 80: MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS | child-key literal(s): POLICY_PREMIUM_HEAD.Adjusted Indicator=N, POLICY_PREMIUM_HEAD.Premium Head Code=BASE_PREMIUM, POLICY_PREMIUM_HEAD.Section=POLICY
    select
        null, null,
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'BASE_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        t0.cover || '@' || t0.member_name as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'POLICY' as POLICY_PREMIUM_HEAD__SECTION_CK,
        'N' as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        t0.base_premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_premium_calculation_dtls') }} t0
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.policy_number),''), '')) is not null

    union all

    -- branch 81: MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS | child-key literal(s): POLICY_PREMIUM_HEAD.Adjusted Indicator=N, POLICY_PREMIUM_HEAD.Premium Head Code=GROSS_PREMIUM, POLICY_PREMIUM_HEAD.Section=POLICY
    select
        null, null,
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'GROSS_PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        t0.cover || '@' || t0.member_name as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'POLICY' as POLICY_PREMIUM_HEAD__SECTION_CK,
        'N' as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        null,
        t0.gross_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_premium_calculation_dtls') }} t0
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.policy_number),''), '')) is not null

)

select
    ASSESSMENT_BK,
    COVERAGE_BK,
    POLICY_BK,
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    __LNK_POLICY_COVERAGE,
    first_value(ASSESSMENT_UNDERWRITING__ACCEPTANCE_DECISION) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__ACCEPTANCE_DECISION,
    first_value(ASSESSMENT_UNDERWRITING__DEVIATION_JUSTIFICATION) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__DEVIATION_JUSTIFICATION,
    first_value(ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR,
    first_value(ASSESSMENT_UNDERWRITING__REINSURANCE_REFERRAL_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__REINSURANCE_REFERRAL_INDICATOR,
    first_value(ASSESSMENT_UNDERWRITING__RISK_GRADE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__RISK_GRADE,
    first_value(ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED,
    first_value(ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS,
    first_value(AUG_RISK_PERSON_INSURED__CONSENT_LETTER_REQUIRED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_PERSON_INSURED__CONSENT_LETTER_REQUIRED_INDICATOR,
    COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE_CK,
    first_value(COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE) ignore nulls over (partition by COVERAGE_BK, COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE,
    first_value(COVERAGE_MEMBER_BENEFIT__BENEFIT_NAME) ignore nulls over (partition by COVERAGE_BK, COVERAGE_MEMBER_BENEFIT__BENEFIT_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_MEMBER_BENEFIT__BENEFIT_NAME,
    POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
    first_value(POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
    first_value(POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__SUB_LIMIT_AMOUNT,
    POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__BASIS) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__ITEM_TYPE) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_TYPE,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
    POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
    POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
    POLICY_PREMIUM_HEAD__SECTION_CK,
    POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
    first_value(POLICY_PREMIUM_HEAD__BASE_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
    first_value(POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
    first_value(PROPOSAL_DECLARATIONS__ADVERSE_HEALTH_DECLARATION_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_DECLARATIONS__ADVERSE_HEALTH_DECLARATION_INDICATOR,
    first_value(PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR,
    first_value(PROPOSAL_DECLARATIONS__MEDICAL_HISTORY_DECLARATION_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_DECLARATIONS__MEDICAL_HISTORY_DECLARATION_INDICATOR,
    RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
    RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
    first_value(RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME) ignore nulls over (partition by RISK_OBJECT_BK, RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK, RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME,
    first_value(RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK, RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR,
    first_value(RISK_HEALTH_MEMBER_MEDICAL__ICD_CODE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK, RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_MEMBER_MEDICAL__ICD_CODE,
    first_value(RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK, RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR,
    first_value(RISK_PERSON_INSURED__BODY_MASS_INDEX) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__BODY_MASS_INDEX,
    first_value(RISK_PERSON_INSURED__CUMULATIVE_BONUS_APPLICABLE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__CUMULATIVE_BONUS_APPLICABLE_INDICATOR,
    first_value(RISK_PERSON_INSURED__DISABILITY_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__DISABILITY_INDICATOR,
    first_value(RISK_PERSON_INSURED__HEALTH_CARD_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__HEALTH_CARD_NUMBER,
    first_value(RISK_PERSON_INSURED__HEIGHT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__HEIGHT,
    first_value(RISK_PERSON_INSURED__OCCUPATION_CLASS_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__OCCUPATION_CLASS_CODE,
    first_value(RISK_PERSON_INSURED__PERMANENT_EXCLUSION_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__PERMANENT_EXCLUSION_INDICATOR,
    first_value(RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_DESCRIPTION) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_DESCRIPTION,
    first_value(RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__PRE_EXISTING_DISEASE_INDICATOR,
    first_value(RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__RELATIONSHIP_TO_PROPOSER
from merged
