-- CENTRAL VIEW v16_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_ENDORSEMENT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_ENDORSEMENT_HISTORY_REPORT
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_RISK_SCORING
--   SAT_AUG_ASSESSMENT_HEADER
--   SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE
--   SAT_AUG_PARTY_IDENTITY
--   SAT_AUG_POLICY_ENDORSEMENT
--   SAT_AUG_POLICY_GROUP
--   SAT_AUG_POLICY_LIFECYCLE
--   SAT_AUG_POLICY_TERMS
--   SAT_AUG_PROPOSAL_HEADER
--   SAT_AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE
--   SAT_COMMON_LIFECYCLE
--   SAT_COMMON_STATUS
--   SAT_LEAD_ATTRIBUTION
--   SAT_LNK_POLICY_PARTY_ROLE
--   SAT_LNK_ROLE_POSP
--   SAT_PARTY_CONSENT_MANDATE
--   SAT_PARTY_GROUP_HOUSEHOLD
--   SAT_POLICY_CANCELLATION
--   SAT_POLICY_DOC_CHECKLIST
--   SAT_POLICY_ENDORSEMENT
--   SAT_POLICY_EXCESS_STRUCTURE
--   SAT_POLICY_INTERMEDIARY_SPLIT
--   SAT_POLICY_LIFECYCLE
--   SAT_POLICY_REFUND_DETAIL
--   SAT_POLICY_RENEWAL
--   SAT_POLICY_SUM_INSURED_BREAKUP
--   SAT_POLICY_TAX_HEAD
--   SAT_POLICY_TENURE_SCHEDULE
--   SAT_POLICY_TERMS
--   SAT_PRODUCT_RATING_STRUCTURE
--   SAT_RISK_HEALTH_PED_WAITING
--   SAT_RISK_HEALTH_WELLNESS
--   SAT_RISK_OBJECT_CORE
--   SAT_RISK_PET
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(t0.pol_policy_number, '') as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as ASSESSMENT_RISK_SCORING__SCORE_BAND,
        cast(null as varchar) as ASSESSMENT_RISK_SCORING__SCORE_VALUE,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__PREVIOUS_ASSESSOR_TYPE,
        cast(null as varchar) as AUG_COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAYS_ALLOWED_PER_MONTH,
        cast(null as varchar) as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAY_COUNT,
        cast(null as varchar) as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_MONTHS_PAYABLE_PER_YEAR,
        cast(null as varchar) as AUG_PARTY_IDENTITY__NAME_INITIAL,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_MERGE_STATUS,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_SUB_STATUS,
        cast(null as varchar) as AUG_POLICY_GROUP__EMPLOYEE_CONTRIBUTION_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_LIFECYCLE__ASSIGNEE_PLACE,
        cast(null as varchar) as AUG_POLICY_TERMS__POLICY_EXCLUSION_DESCRIPTION,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_DATE,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_PERIOD,
        cast(null as varchar) as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        cast(null as varchar) as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        cast(null as varchar) as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        cast(null as varchar) as COMMON_LIFECYCLE__EXPIRY_DATE,
        cast(null as varchar) as COMMON_STATUS__PREVIOUS_STATUS_CODE,
        cast(null as varchar) as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        cast(null as varchar) as LEAD_ATTRIBUTION__LEAD_REFERENCE,
        cast(null as varchar) as LEAD_ATTRIBUTION__PARAMETER_VALUE,
        cast(null as varchar) as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        cast(null as varchar) as LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK,
        cast(null as varchar) as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE,
        cast(null as varchar) as LNK_POLICY_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
        cast(null as varchar) as LNK_ROLE_POSP__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_POSP__POSP_CODE,
        cast(null as varchar) as PARTY_CONSENT_MANDATE__MANDATE_TYPE,
        cast(null as varchar) as PARTY_GROUP_HOUSEHOLD__MEMBER_COUNT,
        t0.cancellation_date as POLICY_CANCELLATION__CANCELLATION_DATE,
        cast(null as varchar) as POLICY_CANCELLATION__CANCELLATION_EFFECTIVE_DATE,
        cast(null as varchar) as POLICY_CANCELLATION__CANCELLATION_REASON,
        cast(null as varchar) as POLICY_CANCELLATION__CANCELLATION_TYPE,
        cast(null as varchar) as POLICY_CANCELLATION__REFUND_AMOUNT,
        cast(null as varchar) as POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as POLICY_DOC_CHECKLIST__RECEIVED_INDICATOR,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        cast(null as varchar) as POLICY_ENDORSEMENT__EFFECTIVE_DATE,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
        cast(null as varchar) as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        cast(null as varchar) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE,
        cast(null as varchar) as POLICY_LIFECYCLE__ASSIGNEE_REFERENCE,
        cast(null as varchar) as POLICY_LIFECYCLE__ASSIGNMENT_INDICATOR,
        cast(null as varchar) as POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as POLICY_REFUND_DETAIL__NET_REFUND_AMOUNT,
        cast(null as varchar) as POLICY_REFUND_DETAIL__REFUND_BASIS,
        cast(null as varchar) as POLICY_REFUND_DETAIL__REFUND_MODE,
        cast(null as varchar) as POLICY_REFUND_DETAIL__REFUND_STATUS,
        cast(null as varchar) as POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE,
        cast(null as varchar) as POLICY_RENEWAL__RENEWAL_BLOCKED_INDICATOR,
        t0.renewal_flag as POLICY_RENEWAL__RENEWAL_STATUS,
        cast(null as varchar) as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        cast(null as varchar) as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_AMOUNT,
        cast(null as varchar) as POLICY_TENURE_SCHEDULE__TENURE_SEQUENCE_CK,
        cast(null as varchar) as POLICY_TENURE_SCHEDULE__TENURE_END_DATE,
        cast(null as varchar) as POLICY_TENURE_SCHEDULE__TENURE_START_DATE,
        cast(null as varchar) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        cast(null as varchar) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        cast(null as varchar) as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
        cast(null as varchar) as POLICY_TERMS__REINSTATEMENT_OF_SUM_INSURED_INDICATOR,
        cast(null as varchar) as POLICY_TERMS__SPECIAL_CONDITIONS,
        cast(null as varchar) as POLICY_TERMS__WAITING_PERIOD,
        cast(null as varchar) as PRODUCT_RATING_STRUCTURE__RATING_METHODOLOGY,
        cast(null as varchar) as RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK,
        cast(null as varchar) as RISK_HEALTH_PED_WAITING__WAITING_PERIOD_MONTHS,
        cast(null as varchar) as RISK_HEALTH_WELLNESS__STEPS_AVERAGE,
        cast(null as varchar) as RISK_HEALTH_WELLNESS__WELLNESS_PROGRAMME_ENROLLED_INDICATOR,
        cast(null as varchar) as RISK_OBJECT_CORE__IDENTIFICATION_REFERENCE,
        cast(null as varchar) as RISK_OBJECT_CORE__RISK_CLASS_CODE,
        cast(null as varchar) as RISK_PET__BREED,
        cast(null as varchar) as RISK_PET__MICROCHIP_NUMBER,
        cast(null as varchar) as RISK_PET__PET_TYPE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd') }} t0
    where (nullif(t0.pol_policy_number, '')) is not null

    union all

    -- branch 1: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), '') as ASSESSMENT_BK,
        null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        nullif(nullif(trim(j2.product_code),''), '') as PRODUCT_BK,
        nullif(nullif(trim(j2.proposal_number),''), '') as PROPOSAL_BK,
        null, null, null,
        t0.mediusrisk_class as ASSESSMENT_RISK_SCORING__SCORE_BAND,
        t0.mediusinsurability_score as ASSESSMENT_RISK_SCORING__SCORE_VALUE,
        null, null, null, null, null, null, null, null, null, null,
        t0.place_of_the_assignee as AUG_POLICY_LIFECYCLE__ASSIGNEE_PLACE,
        t0.exclusion_of as AUG_POLICY_TERMS__POLICY_EXCLUSION_DESCRIPTION,
        t0.quote_expiry_date as AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_DATE,
        t0.quote_validity as AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_PERIOD,
        null, null,
        t0.effective_date as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        t0.expiry_date as COMMON_LIFECYCLE__EXPIRY_DATE,
        t0.previous_policy_substatus as COMMON_STATUS__PREVIOUS_STATUS_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.mandate_type as PARTY_CONSENT_MANDATE__MANDATE_TYPE,
        t0.family_size as PARTY_GROUP_HOUSEHOLD__MEMBER_COUNT,
        t0.cancellation_date as POLICY_CANCELLATION__CANCELLATION_DATE,
        t0.effective_date_of_cancellation as POLICY_CANCELLATION__CANCELLATION_EFFECTIVE_DATE,
        t0.cancellation_cause as POLICY_CANCELLATION__CANCELLATION_REASON,
        t0.cancellation_type as POLICY_CANCELLATION__CANCELLATION_TYPE,
        t0.calculated_amount_for_remaining_period as POLICY_CANCELLATION__REFUND_AMOUNT,
        null, null, null, null, null, null, null, null,
        t0.imd_code as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        t0.commission as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
        t0.commission_ as POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE,
        t0.assignee_name as POLICY_LIFECYCLE__ASSIGNEE_REFERENCE,
        t0.do_you_want_to_assign_the_policy as POLICY_LIFECYCLE__ASSIGNMENT_INDICATOR,
        t0.refund_type as POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.refund_amount as POLICY_REFUND_DETAIL__NET_REFUND_AMOUNT,
        t0.refund_type as POLICY_REFUND_DETAIL__REFUND_BASIS,
        t0.refundreissue as POLICY_REFUND_DETAIL__REFUND_MODE,
        t0.refund_to_be_processed as POLICY_REFUND_DETAIL__REFUND_STATUS,
        t0.parent_policy_number_for_renewal as POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE,
        t0.policy_renewal_applicable as POLICY_RENEWAL__RENEWAL_BLOCKED_INDICATOR,
        null, null, null, null, null, null, null, null,
        t0.voluntary_copay as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
        t0.deductible as POLICY_TERMS__DEDUCTIBLE_TOTAL,
        null,
        t0.sum_insured_reinstatement_applicable as POLICY_TERMS__REINSTATEMENT_OF_SUM_INSURED_INDICATOR,
        t0.policy_special_conditions as POLICY_TERMS__SPECIAL_CONDITIONS,
        t0.ped_waiting_period_months as POLICY_TERMS__WAITING_PERIOD,
        t0.rater_type as PRODUCT_RATING_STRUCTURE__RATING_METHODOLOGY,
        null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), ''), nullif(nullif(trim(j2.policy_number),''), ''), nullif(nullif(trim(j2.product_code),''), ''), nullif(nullif(trim(j2.proposal_number),''), ''), nullif(t0.proposer_code, ''))) is not null

    union all

    -- branch 2: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('UWR-ASSESSMENT:' || nullif(trim(j2.proposal_number),''), '') as ASSESSMENT_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.previous_underwriter_role as AUG_ASSESSMENT_HEADER__PREVIOUS_ASSESSOR_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif('UWR-ASSESSMENT:' || nullif(trim(j2.proposal_number),''), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LEAD_ATTRIBUTION.Attribution Parameter=DM_LEAD
    select
        null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'DM_LEAD' as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        t0.dm_lead as LEAD_ATTRIBUTION__LEAD_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 4: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LEAD_ATTRIBUTION.Attribution Parameter=LG_CODE
    select
        null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'LG_CODE' as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        null,
        t0.lg_code as LEAD_ATTRIBUTION__PARAMETER_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 5: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_POSP.Role Type=POSP
    select
        null, null,
        nullif('POSP:' || nullif(trim(t0.sp_posp_code),''), '') as PARTY_BK,
        null, null, null, null,
        'POSP' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'POSP' as LNK_ROLE_POSP__ROLE_TYPE_CK,
        t0.sp_posp_code as LNK_ROLE_POSP__POSP_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('POSP:' || nullif(trim(t0.sp_posp_code),''), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_DOC_CHECKLIST.Active Sequence Number=ALL_DOCUMENTS
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ALL_DOCUMENTS' as POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.documents_received as POLICY_DOC_CHECKLIST__RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 7: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_EXCESS_STRUCTURE.Excess Code=VOLUNTARY_AGGREGATE
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_AGGREGATE' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.voluntary_aggregate_deductible as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=APPLICABLE_SUM_INSURED
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'APPLICABLE_SUM_INSURED' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.applicable_sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=DOUBLE_SUM_INSURED
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DOUBLE_SUM_INSURED' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.double_sum_insured_benefit as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=FLOATER
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FLOATER' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.floater_sum_insured_amount as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=SUPER_TOP_UP
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUPER_TOP_UP' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.super_top_up_cover_sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_TAX_HEAD.Tax Head Code=UTGST
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UTGST' as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        t0.utgst_amount as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_TENURE_SCHEDULE.Tenure Sequence=POLICY_TERM
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICY_TERM' as POLICY_TENURE_SCHEDULE__TENURE_SEQUENCE_CK,
        t0.period_to as POLICY_TENURE_SCHEDULE__TENURE_END_DATE,
        t0.period_from as POLICY_TENURE_SCHEDULE__TENURE_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_UWR_VW_DATA_ENDORSEMENT_DETAILS
    select
        null, null, null,
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.number as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        t0.merge_status as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_MERGE_STATUS,
        t0.endorsement_substatus as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_SUB_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.number as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        t0.endorsement_effective_date as POLICY_ENDORSEMENT__EFFECTIVE_DATE,
        t0.number as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
        t0.endorsement_type as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_endorsement_dtls') }} t0
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.policy_number),''), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_ENDORSEMENT_HISTORY_REPORT
    select
        null, null, null,
        nullif(t0.policy_no, '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.endorsement_no as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        t0.effective_date as POLICY_ENDORSEMENT__EFFECTIVE_DATE,
        t0.endorsement_no as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
        t0.endorsement_type as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_endorsement_history_report') }} t0
    where (nullif(t0.policy_no, '')) is not null

    union all

    -- branch 16: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), '') as ASSESSMENT_BK,
        null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null,
        t0.mediusinsurability_score as ASSESSMENT_RISK_SCORING__SCORE_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.cancellation_date as POLICY_CANCELLATION__CANCELLATION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nd_refund_type as POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK,
        null,
        t0.nd_refund_type as POLICY_REFUND_DETAIL__REFUND_BASIS,
        null, null, null, null, null, null,
        coalesce(t0.self_applicable_sum_insured, t0.self_si) as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null,
        t0.region_of_cover as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
        null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) || '#' || 'PRE_EXISTING_DISEASE' as RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK,
        t0.self_ped_waiting_period_months as RISK_HEALTH_PED_WAITING__WAITING_PERIOD_MONTHS,
        t0.daily_steps_count as RISK_HEALTH_WELLNESS__STEPS_AVERAGE,
        t0.walk_to_win as RISK_HEALTH_WELLNESS__WELLNESS_PROGRAMME_ENROLLED_INDICATOR,
        t0.unique_identification_description as RISK_OBJECT_CORE__IDENTIFICATION_REFERENCE,
        t0.risk_class as RISK_OBJECT_CORE__RISK_CLASS_CODE,
        null, null, null,
        4 as __PREC,
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
    where (coalesce(nullif('MEDIUS:' || nullif(trim(t0.mediusapplication_id),''), ''), nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), ''), nullif(nullif(trim(j3.policy_number),''), ''))) is not null

    union all

    -- branch 17: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): AUG_COVERAGE_SUBLIMIT_SCHEDULE.Active Sequence Number=BENEFIT_DAYS
    select
        null,
        nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null,
        'BENEFIT_DAYS' as AUG_COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.no_of_days_count_per_month as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAYS_ALLOWED_PER_MONTH,
        t0.no_of_days as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAY_COUNT,
        t0.no_of_months_per_year as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_MONTHS_PAYABLE_PER_YEAR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('COV:' || nullif(trim(coalesce(nullif(trim(t0.product_code),''),'') || '#' || coalesce(nullif(trim(t0.plan),''),'') || '#' || coalesce(nullif(trim(t0.sub_plan),''),'')), '##'), '')) is not null

    union all

    -- branch 18: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_EXCESS_STRUCTURE.Excess Code=VOLUNTARY_DEDUCTIBLE
    select
        null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.voluntary_deductible as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=SUPER_TOP_UP
    select
        null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUPER_TOP_UP' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.super_top_up_cover_sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 20: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=WIDER
    select
        null, null, null,
        nullif(nullif(trim(j3.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WIDER' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.wider_sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number),''), '')) is not null

    union all

    -- branch 21: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_PED_WAITING.Condition Code=PRE_EXISTING_DISEASE
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'PRE_EXISTING_DISEASE' as RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK,
        t0.ped_waiting_period_months as RISK_HEALTH_PED_WAITING__WAITING_PERIOD_MONTHS,
        null, null, null, null, null, null, null,
        4 as __PREC,
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

    -- branch 22: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.health_card_number),'')) || '#' || 'SPECIFIC_DISEASE' as RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK,
        t0.self_specific_disease_waiting_period as RISK_HEALTH_PED_WAITING__WAITING_PERIOD_MONTHS,
        null, null, null, null, null, null, null,
        4 as __PREC,
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

    -- branch 23: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_PED_WAITING.Condition Code=SPECIFIC_DISEASE
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'SPECIFIC_DISEASE' as RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK,
        t0.specific_disease_waiting_period as RISK_HEALTH_PED_WAITING__WAITING_PERIOD_MONTHS,
        null, null, null, null, null, null, null,
        4 as __PREC,
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

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): RISK_HEALTH_PED_WAITING.Condition Code=INITIAL_WAITING
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'INITIAL_WAITING' as RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK,
        t0.waiting_period_duration as RISK_HEALTH_PED_WAITING__WAITING_PERIOD_MONTHS,
        null, null, null, null, null, null, null,
        4 as __PREC,
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

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('PET:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.insured_pet_breed as RISK_PET__BREED,
        null,
        t0.insured_pet_species as RISK_PET__PET_TYPE,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('PET:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 26: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('PET:' || nullif(trim(t0.pet_identification_tag_rfid_microchip_details),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.pet_identification_tag_rfid_microchip_details as RISK_PET__MICROCHIP_NUMBER,
        null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    where (nullif('PET:' || nullif(trim(t0.pet_identification_tag_rfid_microchip_details),''), '')) is not null

    union all

    -- branch 27: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
    select
        null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.initial as AUG_PARTY_IDENTITY__NAME_INITIAL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 28: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY | child-key literal(s): LNK_POLICY_PARTY_ROLE.Party Role Type=MEMBER, LNK_POLICY_PARTY_ROLE.Role Sequence=1
    select
        null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '') as POLICY_BK,
        null, null, null, null,
        1 as __LNK_POLICY_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MEMBER' as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK,
        null,
        t0.effective_date as LNK_POLICY_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party') }} t0
    left join {{ ref('stg_mxh__uwr_members') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), ''), nullif(nullif(trim(t0.party_code),''), ''))) is not null

    union all

    -- branch 29: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=CCP_1
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CCP_1' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.ccp_1 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 30: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=CCP_2
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CCP_2' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.ccp_2 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 31: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=CHLP_1
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CHLP_1' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.chlp_1 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 32: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=CHLP_2
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CHLP_2' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.chlp_2 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 33: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=CRITICARE
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CRITICARE' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.criticare as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 34: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=CRITICARE_1
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CRITICARE_1' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.criticare_1 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 35: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=GLOBALSET
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GLOBALSET' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.globalset as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 36: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=HERIZON_CARE_PLAN_1
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'HERIZON_CARE_PLAN_1' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.herizon_care_plan_1 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 37: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=HERIZON_CARE_PLAN_2
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'HERIZON_CARE_PLAN_2' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.herizon_care_plan_2 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 38: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=HERIZON_CARE_PLAN_3
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'HERIZON_CARE_PLAN_3' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.herizon_care_plan_3 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 39: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=INFINITY_1
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INFINITY_1' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.infinity_1 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 40: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=INFINITY_2
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INFINITY_2' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.infinity_2 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 41: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=NIDAAN_SWASTHYA_1
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NIDAAN_SWASTHYA_1' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.nidaan_swasthya_1 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 42: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=PORT_SET
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PORT_SET' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.port_set as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 43: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=SET1
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SET1' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.set1 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 44: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=VHC
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VHC' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.vhc as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 45: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=WOMEN_SPECIFIC_CRITICAL_ILLNESS_1
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WOMEN_SPECIFIC_CRITICAL_ILLNESS_1' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.women_specific_critical_illness_1 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 46: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW | child-key literal(s): AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE.Package Code=WOMEN_SPECIFIC_CRITICAL_ILLNESS_2
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WOMEN_SPECIFIC_CRITICAL_ILLNESS_2' as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
        t0.women_specific_critical_illness_2 as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_ppc_package_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_ppc_package') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif('MEMBER:' || (nullif(trim((case when x1._N = 1 then x1._V end)),'')), '')) is not null

    union all

    -- branch 47: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.employee_contribution_percentage as AUG_POLICY_GROUP__EMPLOYEE_CONTRIBUTION_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    left join {{ ref('stg_mxh__uwr_payment_info') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 48: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): LNK_POLICY_PARTY_ROLE.Role Sequence=1
    select
        null, null,
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null,
        1 as __LNK_POLICY_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payer_type as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK,
        t0.payer_type as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    left join {{ ref('stg_mxh__uwr_payment_info') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), ''), nullif(nullif(trim(j2.policy_number),''), ''))) is not null

    union all

    -- branch 49: MAXI_HLTH_UWR_VW_DATA_RELATIONS | child-key literal(s): LNK_POLICY_PARTY_ROLE.Role Sequence=1
    select
        null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null,
        1 as __LNK_POLICY_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.role as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK,
        t0.role as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations') }} t0
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = t0.KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j1.policy_number),''), ''))) is not null

    union all

    -- branch 50: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
    select
        null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.initial as AUG_PARTY_IDENTITY__NAME_INITIAL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 51: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY | child-key literal(s): LNK_POLICY_PARTY_ROLE.Role Sequence=1
    select
        null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), '') as POLICY_BK,
        null, null, null, null,
        1 as __LNK_POLICY_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        '1' as LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK,
        null,
        t0.effective_date as LNK_POLICY_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party') }} t0
    left join {{ ref('stg_mxh__uwr_relations') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce( nullif(trim(j2.policy_number),'') ,'PROPOSAL:' || nullif(trim(j2.proposal_number),'') ), ''), nullif(nullif(trim(t0.party_code),''), ''))) is not null

)

select
    ASSESSMENT_BK,
    COVERAGE_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    ROLE_TYPE_CODE,
    __LNK_POLICY_PARTY,
    first_value(ASSESSMENT_RISK_SCORING__SCORE_BAND) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_RISK_SCORING__SCORE_BAND,
    first_value(ASSESSMENT_RISK_SCORING__SCORE_VALUE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_RISK_SCORING__SCORE_VALUE,
    first_value(AUG_ASSESSMENT_HEADER__PREVIOUS_ASSESSOR_TYPE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__PREVIOUS_ASSESSOR_TYPE,
    AUG_COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAYS_ALLOWED_PER_MONTH) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAYS_ALLOWED_PER_MONTH,
    first_value(AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAY_COUNT) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAY_COUNT,
    first_value(AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_MONTHS_PAYABLE_PER_YEAR) ignore nulls over (partition by COVERAGE_BK, AUG_COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_MONTHS_PAYABLE_PER_YEAR,
    first_value(AUG_PARTY_IDENTITY__NAME_INITIAL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__NAME_INITIAL,
    AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
    first_value(AUG_POLICY_ENDORSEMENT__ENDORSEMENT_MERGE_STATUS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_MERGE_STATUS,
    first_value(AUG_POLICY_ENDORSEMENT__ENDORSEMENT_SUB_STATUS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_SUB_STATUS,
    first_value(AUG_POLICY_GROUP__EMPLOYEE_CONTRIBUTION_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_GROUP__EMPLOYEE_CONTRIBUTION_PERCENTAGE,
    first_value(AUG_POLICY_LIFECYCLE__ASSIGNEE_PLACE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_LIFECYCLE__ASSIGNEE_PLACE,
    first_value(AUG_POLICY_TERMS__POLICY_EXCLUSION_DESCRIPTION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__POLICY_EXCLUSION_DESCRIPTION,
    first_value(AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_DATE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_DATE,
    first_value(AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_PERIOD) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_PERIOD,
    AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK,
    first_value(AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_HEALTH_MEMBER_PPC_PACKAGE__PACKAGE_SELECTION_VALUE,
    first_value(COMMON_LIFECYCLE__EFFECTIVE_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_LIFECYCLE__EFFECTIVE_DATE,
    first_value(COMMON_LIFECYCLE__EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_LIFECYCLE__EXPIRY_DATE,
    first_value(COMMON_STATUS__PREVIOUS_STATUS_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_STATUS__PREVIOUS_STATUS_CODE,
    LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
    first_value(LEAD_ATTRIBUTION__LEAD_REFERENCE) ignore nulls over (partition by PARTY_BK, LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LEAD_ATTRIBUTION__LEAD_REFERENCE,
    first_value(LEAD_ATTRIBUTION__PARAMETER_VALUE) ignore nulls over (partition by PARTY_BK, LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LEAD_ATTRIBUTION__PARAMETER_VALUE,
    LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
    LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK,
    first_value(LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE) ignore nulls over (partition by PARTY_BK, POLICY_BK, LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE,
    first_value(LNK_POLICY_PARTY_ROLE__ROLE_EFFECTIVE_DATE) ignore nulls over (partition by PARTY_BK, POLICY_BK, LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_POLICY_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
    LNK_ROLE_POSP__ROLE_TYPE_CK,
    first_value(LNK_ROLE_POSP__POSP_CODE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_POSP__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_POSP__POSP_CODE,
    first_value(PARTY_CONSENT_MANDATE__MANDATE_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CONSENT_MANDATE__MANDATE_TYPE,
    first_value(PARTY_GROUP_HOUSEHOLD__MEMBER_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_GROUP_HOUSEHOLD__MEMBER_COUNT,
    first_value(POLICY_CANCELLATION__CANCELLATION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_DATE,
    first_value(POLICY_CANCELLATION__CANCELLATION_EFFECTIVE_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_EFFECTIVE_DATE,
    first_value(POLICY_CANCELLATION__CANCELLATION_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_REASON,
    first_value(POLICY_CANCELLATION__CANCELLATION_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_TYPE,
    first_value(POLICY_CANCELLATION__REFUND_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__REFUND_AMOUNT,
    POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(POLICY_DOC_CHECKLIST__RECEIVED_INDICATOR) ignore nulls over (partition by POLICY_BK, POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DOC_CHECKLIST__RECEIVED_INDICATOR,
    POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
    first_value(POLICY_ENDORSEMENT__EFFECTIVE_DATE) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__EFFECTIVE_DATE,
    first_value(POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
    first_value(POLICY_ENDORSEMENT__ENDORSEMENT_TYPE) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
    POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
    first_value(POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
    POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
    first_value(POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
    first_value(POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE,
    first_value(POLICY_LIFECYCLE__ASSIGNEE_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_LIFECYCLE__ASSIGNEE_REFERENCE,
    first_value(POLICY_LIFECYCLE__ASSIGNMENT_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_LIFECYCLE__ASSIGNMENT_INDICATOR,
    POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(POLICY_REFUND_DETAIL__NET_REFUND_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_REFUND_DETAIL__NET_REFUND_AMOUNT,
    first_value(POLICY_REFUND_DETAIL__REFUND_BASIS) ignore nulls over (partition by POLICY_BK, POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_REFUND_DETAIL__REFUND_BASIS,
    first_value(POLICY_REFUND_DETAIL__REFUND_MODE) ignore nulls over (partition by POLICY_BK, POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_REFUND_DETAIL__REFUND_MODE,
    first_value(POLICY_REFUND_DETAIL__REFUND_STATUS) ignore nulls over (partition by POLICY_BK, POLICY_REFUND_DETAIL__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_REFUND_DETAIL__REFUND_STATUS,
    first_value(POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE,
    first_value(POLICY_RENEWAL__RENEWAL_BLOCKED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_BLOCKED_INDICATOR,
    first_value(POLICY_RENEWAL__RENEWAL_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_STATUS,
    POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
    first_value(POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
    POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
    first_value(POLICY_TAX_HEAD__TAX_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_HEAD__TAX_AMOUNT,
    POLICY_TENURE_SCHEDULE__TENURE_SEQUENCE_CK,
    first_value(POLICY_TENURE_SCHEDULE__TENURE_END_DATE) ignore nulls over (partition by POLICY_BK, POLICY_TENURE_SCHEDULE__TENURE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TENURE_SCHEDULE__TENURE_END_DATE,
    first_value(POLICY_TENURE_SCHEDULE__TENURE_START_DATE) ignore nulls over (partition by POLICY_BK, POLICY_TENURE_SCHEDULE__TENURE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TENURE_SCHEDULE__TENURE_START_DATE,
    first_value(POLICY_TERMS__CO_PAYMENT_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__CO_PAYMENT_PERCENTAGE,
    first_value(POLICY_TERMS__DEDUCTIBLE_TOTAL) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__DEDUCTIBLE_TOTAL,
    first_value(POLICY_TERMS__GEOGRAPHICAL_SCOPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
    first_value(POLICY_TERMS__REINSTATEMENT_OF_SUM_INSURED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__REINSTATEMENT_OF_SUM_INSURED_INDICATOR,
    first_value(POLICY_TERMS__SPECIAL_CONDITIONS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__SPECIAL_CONDITIONS,
    first_value(POLICY_TERMS__WAITING_PERIOD) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__WAITING_PERIOD,
    first_value(PRODUCT_RATING_STRUCTURE__RATING_METHODOLOGY) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RATING_STRUCTURE__RATING_METHODOLOGY,
    RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK,
    first_value(RISK_HEALTH_PED_WAITING__WAITING_PERIOD_MONTHS) ignore nulls over (partition by RISK_OBJECT_BK, RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_PED_WAITING__WAITING_PERIOD_MONTHS,
    first_value(RISK_HEALTH_WELLNESS__STEPS_AVERAGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_WELLNESS__STEPS_AVERAGE,
    first_value(RISK_HEALTH_WELLNESS__WELLNESS_PROGRAMME_ENROLLED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_HEALTH_WELLNESS__WELLNESS_PROGRAMME_ENROLLED_INDICATOR,
    first_value(RISK_OBJECT_CORE__IDENTIFICATION_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__IDENTIFICATION_REFERENCE,
    first_value(RISK_OBJECT_CORE__RISK_CLASS_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__RISK_CLASS_CODE,
    first_value(RISK_PET__BREED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PET__BREED,
    first_value(RISK_PET__MICROCHIP_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PET__MICROCHIP_NUMBER,
    first_value(RISK_PET__PET_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PET__PET_TYPE
from merged
