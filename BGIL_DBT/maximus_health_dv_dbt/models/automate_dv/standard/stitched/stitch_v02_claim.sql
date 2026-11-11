-- CENTRAL VIEW v02_claim -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_AUTHORIZATION_REMARKS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_COPAY_DETAILS_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_FOLLOW_UP_REPORT_ATTRIBUTES_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA
--   MAXI_HLTH_CLM_VW_DATA_AUTHORIZATION_REMARKS
--   MAXI_HLTH_CLM_VW_DATA_AUTHORIZATION_REMARKS_MULTISET_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_AUTHORIZATION_REMARKS_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_COPAY_DETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_COPAY_DETAILS_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_MULTISET_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_FOLLOW_UP_REPORT
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_FOLLOW_UP_REPORT_ATTRIBUTES
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_ASSESSMENT_SUMMARY
--   SAT_AUG_CLAIM_BENEFIT_HEAD
--   SAT_AUG_CLAIM_FRAUD
--   SAT_AUG_CLAIM_HEADER
--   SAT_AUG_CLAIM_HEALTH_DETAIL
--   SAT_AUG_CLAIM_PA_DETAIL
--   SAT_AUG_CLAIM_PROVIDER_BILLING
--   SAT_AUG_CLAIM_QUALITY_AUDIT
--   SAT_AUG_CLAIM_RECOVERY_SALVAGE
--   SAT_AUG_CLAIM_TPA_INTERACTION
--   SAT_AUG_DOCUMENT_DEFINITION
--   SAT_AUG_POLICY_FOLLOW_UP_LOG
--   SAT_AUG_PROVIDER_TARIFF
--   SAT_CLAIM_ASSESSMENT_SUMMARY
--   SAT_CLAIM_BENEFIT_HEAD
--   SAT_CLAIM_HEALTH_DETAIL
--   SAT_CLAIM_NETWORK_VERIFICATION
--   SAT_CLAIM_PA_DETAIL
--   SAT_CLAIM_PROVIDER_BILLING
--   SAT_CLAIM_REPUDIATION
--   SAT_CLAIM_TPA_INTERACTION
--   SAT_LOSS_EVENT_DETAIL
--   SAT_POLICY_CLAUSE_ATTACHED
--   SAT_PROVIDER_TARIFF
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_COVERAGE
--   LNK_CLAIM_LOSS_EVENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_AUTHORIZATION_REMARKS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as CLAIM_BK,
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as DOCUMENT_BK,
        cast(null as varchar) as LOSS_EVENT_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_CLAIM_COVERAGE,
        cast(null as number) as __LNK_CLAIM_LOSS_EVENT,
        cast(null as varchar) as AUG_CLAIM_ASSESSMENT_SUMMARY__AUTO_ADJUDICATION_ENGINE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__BALANCE_SUM_INSURED,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_MULTIPLIER,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PAYABLE_PERCENTAGE,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PERIOD_FROM_DATE,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PERIOD_TO_DATE,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__CLAIMED_BENEFIT_WEEKS,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__CLAIMED_NUMBER_OF_DAYS,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__ELIGIBLE_BENEFIT_DAYS,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__ELIGIBLE_BENEFIT_WEEKS,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__INCURRED_EXPENSE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__LAST_EMI_PAID_DATE,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__MAXIMUM_BENEFIT_WEEKS_APPROVED,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__NSBP_COVERAGE_DETAIL,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__ORIGINAL_APPROVED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__OTHER_ATTRIBUTE_VALUE,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__OUTSTANDING_LOAN_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__PER_SITTING_CHARGE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__PREVIOUS_APPROVED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__SITTING_COUNT,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__SUM_INSURED_PAYABLE_PERCENTAGE,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__SYSTEM_CALCULATED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_BENEFIT_HEAD__TOTAL_BENEFIT_APPROVED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_FRAUD__SUSPICIOUS_CHECK_BYPASS_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_HEADER__CLAIM_SUB_TYPE,
        cast(null as varchar) as AUG_CLAIM_HEADER__REGISTRATION_TYPE,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__ADMISSION_TYPE,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__ASSISTED_REPRODUCTIVE_TECHNOLOGY_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__BODY_MASS_INDEX,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__CRITICAL_ILLNESS_CATEGORY,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__CRITICAL_ILLNESS_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__EXPECTED_ADMISSION_DATE,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__FITNESS_CERTIFICATION_DATE,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__GRAVIDA_COUNT,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__HOSPITALISATION_TYPE,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__LIVING_CHILDREN_COUNT,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__PREGNANCY_TERMINATION_COUNT,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__PRETERM_BIRTH_COUNT,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__PROVIDER_ADDRESS,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__RADIOLOGIST_DETAIL,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__SECOND_OPINION_COUNT,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__SERVICE_RENDERED_DATE,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__SEVERE_COMORBIDITY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__SYSTEM_OF_MEDICINE,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__TEST_PACKAGE_DETAIL,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__TOTAL_CO_PAY_AND_DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__TRANSPORTATION_MODE,
        cast(null as varchar) as AUG_CLAIM_HEALTH_DETAIL__TREATMENT_SUB_TYPE,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__DISABILITY_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION_WEEKS,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__LEAVE_DURATION,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_FROM_DATE,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_TO_DATE,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__MEMBER_DISABILITY_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_PA_DETAIL__NSBP_IPTT_DISABILITY_TYPE,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__ADDITIONAL_BILL_DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__APPROVED_QUANTITY,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILLED_QUANTITY,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__BILL_GST_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_GST_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_ITEM_CODE,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_ITEM_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__INVOICE_RAISED_AGAINST_INSURER_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__MANUAL_REJECTION_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__NON_MEDICAL_EXPENSE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__NON_MEDICAL_ITEMS,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__NUMBER_OF_SITTINGS,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__OVERRIDE_REMARKS,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PAYMENT_RECEIVED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PER_SITTING_CHARGE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PHARMACY_RETURN_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__PHARMACY_RETURN_DEDUCTED_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__REASONABLE_AND_CUSTOMARY_CHARGE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__REASONABLE_AND_CUSTOMARY_DEDUCTION_REMARKS,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__SERVICE_RENDERED_DATE,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__TARIFF_INDICATOR_TYPE,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__UNIT_OF_MEASURE,
        cast(null as varchar) as AUG_CLAIM_PROVIDER_BILLING__UNIT_TYPE,
        cast(null as varchar) as AUG_CLAIM_QUALITY_AUDIT__QUALITY_CHECK_REMARKS,
        cast(null as varchar) as AUG_CLAIM_QUALITY_AUDIT__SPECIAL_AUTHORITY_OBSERVATION,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_ADJUSTED_AGAINST_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_ADJUSTED_FROM_OTHER_CLAIM_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_DETAIL_DESCRIPTION,
        cast(null as varchar) as AUG_CLAIM_TPA_INTERACTION__TPA_BILLING_DETAIL,
        cast(null as varchar) as AUG_CLAIM_TPA_INTERACTION__TPA_NAME,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__COURIER_PROOF_OF_DELIVERY_NUMBER,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__SECONDARY_DOCUMENT_TYPE,
        cast(null as varchar) as AUG_DOCUMENT_DEFINITION__SENDER_DESPATCH_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK,
        cast(null as varchar) as AUG_POLICY_FOLLOW_UP_LOG__EFFECTIVE_DATE,
        cast(null as varchar) as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_DATE,
        cast(null as varchar) as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_REMARKS,
        cast(null as varchar) as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIME,
        cast(null as varchar) as AUG_POLICY_FOLLOW_UP_LOG__RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE,
        cast(null as varchar) as AUG_POLICY_FOLLOW_UP_LOG__STATUS_CODE,
        cast(null as varchar) as AUG_POLICY_FOLLOW_UP_LOG__SUB_STATUS_CODE,
        cast(null as varchar) as AUG_PROVIDER_TARIFF__SERVICE_CODE_CK,
        cast(null as varchar) as AUG_PROVIDER_TARIFF__I3_TARIFF_PRICE,
        cast(null as varchar) as AUG_PROVIDER_TARIFF__I3_TARIFF_REMARKS,
        cast(null as varchar) as AUG_PROVIDER_TARIFF__SERVICE_TYPE_CODE,
        cast(null as varchar) as AUG_PROVIDER_TARIFF__SERVICE_TYPE_DESCRIPTION,
        cast(null as varchar) as CLAIM_ASSESSMENT_SUMMARY__DEDUCTIBLE_APPLIED,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__ASSESSED_AMOUNT,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__CO_PAY_APPLIED,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__DEDUCTION_AMOUNT,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__DEDUCTION_REASON,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION,
        cast(null as varchar) as CLAIM_BENEFIT_HEAD__STATUS,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__ADMISSION_DATE,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__ADMISSION_TIME,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__AILMENT_DESCRIPTION,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__AYUSH_TREATMENT_INDICATOR,
        t0.authorization_code as CLAIM_HEALTH_DETAIL__CASHLESS_AUTHORISATION_NUMBER,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__DEDUCTIBLE_DETAIL,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__DIAGNOSIS_CODE,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__DISALLOWED_AMOUNT,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__DISCHARGE_DATE,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__DISCHARGE_TIME,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__ELIGIBLE_ROOM_CATEGORY,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__ELIGIBLE_ROOM_RENT,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__EXPECTED_DISCHARGE_DATE,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__HOSPITAL_REFERENCE,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__ICD_CODE,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__IPD_NUMBER,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__LENGTH_OF_STAY,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__NETWORK_DISCOUNT_AMOUNT,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__PROCEDURE_CODE,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__PROCEDURE_DESCRIPTION,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__ROOM_CATEGORY,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__TREATING_DOCTOR_NAME,
        cast(null as varchar) as CLAIM_HEALTH_DETAIL__TREATMENT_TYPE,
        cast(null as varchar) as CLAIM_NETWORK_VERIFICATION__TARIFF_APPLICABLE_INDICATOR,
        cast(null as varchar) as CLAIM_PA_DETAIL__DISABILITY_TYPE,
        cast(null as varchar) as CLAIM_PA_DETAIL__NUMBER_OF_WEEKS,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        cast(null as varchar) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        cast(null as varchar) as CLAIM_REPUDIATION__REPUDIATION_REASON,
        t0.authorization_message as CLAIM_TPA_INTERACTION__AUTHORISATION_MESSAGE,
        cast(null as varchar) as CLAIM_TPA_INTERACTION__DENIAL_INDICATOR,
        cast(null as varchar) as CLAIM_TPA_INTERACTION__DENIAL_REASON,
        cast(null as varchar) as CLAIM_TPA_INTERACTION__TPA_REFERENCE,
        cast(null as varchar) as LOSS_EVENT_DETAIL__CAUSE_OF_LOSS,
        cast(null as varchar) as LOSS_EVENT_DETAIL__LOSS_DATE,
        cast(null as varchar) as LOSS_EVENT_DETAIL__LOSS_DESCRIPTION,
        cast(null as varchar) as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK,
        cast(null as varchar) as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE,
        cast(null as varchar) as POLICY_CLAUSE_ATTACHED__CLAUSE_TITLE,
        cast(null as varchar) as PROVIDER_TARIFF__SERVICE_CODE_CK,
        cast(null as varchar) as PROVIDER_TARIFF__PACKAGE_RATE,
        cast(null as varchar) as PROVIDER_TARIFF__SERVICE_CODE,
        cast(null as varchar) as PROVIDER_TARIFF__SERVICE_DESCRIPTION,
        cast(null as varchar) as PROVIDER_TARIFF__TARIFF_RATE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_auth_remarks_msa_pv') }} t0
    left join {{ ref('stg_mxh__clm_auth_remarks_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_auth_remarks_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_auth_remarks') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.claim_number) as _V, count(distinct d0.claim_number) as _N
            from {{ ref('stg_mxh__clm_cd') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j4.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL | child-key literal(s): CLAIM_BENEFIT_HEAD.Benefit Head Code=TOTAL
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL' as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null, null,
        t0.total_claimed_amount as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j4.claim_number),''), '') as CLAIM_BK,
        null, null, null, null,
        nullif(nullif(trim(j8.pol_policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0._coverservicepackagebenefit as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null, null, null, null, null, null,
        t0._coverservicepackagebenefit as CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION,
        null, null, null,
        t0.diagnosis as CLAIM_HEALTH_DETAIL__AILMENT_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.icd_code as CLAIM_HEALTH_DETAIL__ICD_CODE,
        null, null, null,
        t0.cpt_code as CLAIM_HEALTH_DETAIL__PROCEDURE_CODE,
        t0.cpt_code_description as CLAIM_HEALTH_DETAIL__PROCEDURE_DESCRIPTION,
        null, null,
        t0.type_of_treatment as CLAIM_HEALTH_DETAIL__TREATMENT_TYPE,
        null, null, null, null, null, null, null, null,
        t0.repudiation_remarks as CLAIM_REPUDIATION__REPUDIATION_REASON,
        null,
        t0.denial_decision as CLAIM_TPA_INTERACTION__DENIAL_INDICATOR,
        t0.denial_description as CLAIM_TPA_INTERACTION__DENIAL_REASON,
        null, null, null, null,
        t0.clause_code as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK,
        t0.clause_code as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE,
        t0.clause_description as POLICY_CLAUSE_ATTACHED__CLAUSE_TITLE,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr_msa') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr_msa') }} j5 on j5.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr_multiset_attr') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j7 on j7.KEY_HASH = j6.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j8 on j8.KEY_HASH = j7.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.claim_number),''), ''), nullif(nullif(trim(j8.pol_policy_number),''), ''))) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null,
        nullif(t0.document_id, '') as DOCUMENT_BK,
        nullif('CLM-LOSS:' || nullif(trim(t0.claim_number),''), '') as LOSS_EVENT_BK,
        null, null, null, null,
        t0.vitraya_flag as AUG_CLAIM_ASSESSMENT_SUMMARY__AUTO_ADJUDICATION_ENGINE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.suspicious_bypass_flag as AUG_CLAIM_FRAUD__SUSPICIOUS_CHECK_BYPASS_INDICATOR,
        t0.sub_type_name as AUG_CLAIM_HEADER__CLAIM_SUB_TYPE,
        t0.registration_type as AUG_CLAIM_HEADER__REGISTRATION_TYPE,
        t0.type_of_admission as AUG_CLAIM_HEALTH_DETAIL__ADMISSION_TYPE,
        null, null, null, null,
        t0.probable_doa as AUG_CLAIM_HEALTH_DETAIL__EXPECTED_ADMISSION_DATE,
        null, null,
        t0.type_of_hospitalization2 as AUG_CLAIM_HEALTH_DETAIL__HOSPITALISATION_TYPE,
        null, null, null, null,
        t0.radiologist_details as AUG_CLAIM_HEALTH_DETAIL__RADIOLOGIST_DETAIL,
        null,
        t0.service_date as AUG_CLAIM_HEALTH_DETAIL__SERVICE_RENDERED_DATE,
        null,
        t0.system_of_medicine_used as AUG_CLAIM_HEALTH_DETAIL__SYSTEM_OF_MEDICINE,
        t0.test_package_details as AUG_CLAIM_HEALTH_DETAIL__TEST_PACKAGE_DETAIL,
        t0.total_co_pay_deductible_amount as AUG_CLAIM_HEALTH_DETAIL__TOTAL_CO_PAY_AND_DEDUCTIBLE_AMOUNT,
        null,
        t0.sub_treatment_type as AUG_CLAIM_HEALTH_DETAIL__TREATMENT_SUB_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.settlement_qc_remarks as AUG_CLAIM_QUALITY_AUDIT__QUALITY_CHECK_REMARKS,
        t0.special_power_observation_free_text as AUG_CLAIM_QUALITY_AUDIT__SPECIAL_AUTHORITY_OBSERVATION,
        t0.recovery_from_other_claim_number as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_ADJUSTED_AGAINST_CLAIM_REFERENCE,
        t0.recovery_amount_from_other_claim as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_ADJUSTED_FROM_OTHER_CLAIM_AMOUNT,
        t0.recovery_details as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_DETAIL_DESCRIPTION,
        t0.tpa_billing as AUG_CLAIM_TPA_INTERACTION__TPA_BILLING_DETAIL,
        t0.group_tpa_name as AUG_CLAIM_TPA_INTERACTION__TPA_NAME,
        t0.pod_no as AUG_DOCUMENT_DEFINITION__COURIER_PROOF_OF_DELIVERY_NUMBER,
        t0.type_of_document2 as AUG_DOCUMENT_DEFINITION__SECONDARY_DOCUMENT_TYPE,
        t0.sender_pod as AUG_DOCUMENT_DEFINITION__SENDER_DESPATCH_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.feature_claim as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null,
        t0.feature_claim as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE,
        null, null, null, null, null, null,
        t0.date_of_admission as CLAIM_HEALTH_DETAIL__ADMISSION_DATE,
        t0.time_of_admission as CLAIM_HEALTH_DETAIL__ADMISSION_TIME,
        t0.reason_for_hospitalisation as CLAIM_HEALTH_DETAIL__AILMENT_DESCRIPTION,
        null,
        t0.preauth_number as CLAIM_HEALTH_DETAIL__CASHLESS_AUTHORISATION_NUMBER,
        t0.deductable_details as CLAIM_HEALTH_DETAIL__DEDUCTIBLE_DETAIL,
        t0.diagnosis as CLAIM_HEALTH_DETAIL__DIAGNOSIS_CODE,
        t0.total_rejected_amount as CLAIM_HEALTH_DETAIL__DISALLOWED_AMOUNT,
        t0.date_of_discharge as CLAIM_HEALTH_DETAIL__DISCHARGE_DATE,
        t0.time_of_discharge as CLAIM_HEALTH_DETAIL__DISCHARGE_TIME,
        t0.eligible_room_category as CLAIM_HEALTH_DETAIL__ELIGIBLE_ROOM_CATEGORY,
        t0.eligible_room_rent as CLAIM_HEALTH_DETAIL__ELIGIBLE_ROOM_RENT,
        t0.probable_dod as CLAIM_HEALTH_DETAIL__EXPECTED_DISCHARGE_DATE,
        null,
        t0.icd_details as CLAIM_HEALTH_DETAIL__ICD_CODE,
        t0.ipd_number as CLAIM_HEALTH_DETAIL__IPD_NUMBER,
        t0.no_of_hospitalization_days as CLAIM_HEALTH_DETAIL__LENGTH_OF_STAY,
        t0.total_discount_amount as CLAIM_HEALTH_DETAIL__NETWORK_DISCOUNT_AMOUNT,
        t0.cpt_details as CLAIM_HEALTH_DETAIL__PROCEDURE_CODE,
        null,
        t0.room_type as CLAIM_HEALTH_DETAIL__ROOM_CATEGORY,
        t0.name_of_the_treating_doctor as CLAIM_HEALTH_DETAIL__TREATING_DOCTOR_NAME,
        t0.type_of_treatment as CLAIM_HEALTH_DETAIL__TREATMENT_TYPE,
        null, null, null,
        t0.bill_number as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        t0.total_billed_amount as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        t0.bill_number as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        null, null,
        t0.reason_of_rejection_of_claim as CLAIM_REPUDIATION__REPUDIATION_REASON,
        null, null,
        t0.denial_reason as CLAIM_TPA_INTERACTION__DENIAL_REASON,
        t0.tpa_claim_number as CLAIM_TPA_INTERACTION__TPA_REFERENCE,
        t0.cause_of_accident as LOSS_EVENT_DETAIL__CAUSE_OF_LOSS,
        t0.date_of_loss as LOSS_EVENT_DETAIL__LOSS_DATE,
        t0.description_death as LOSS_EVENT_DETAIL__LOSS_DESCRIPTION,
        null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (coalesce(nullif('CLM-LOSS:' || nullif(trim(t0.claim_number),''), ''), nullif(t0.claim_number, ''), nullif(t0.document_id, ''))) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLAUSE_ATTACHED.Clause Code=CRC
    select
        null, null, null, null, null,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CRC' as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK,
        t0.crc_clause as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE,
        null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.pol_policy_number),''), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_COPAY_DETAILS_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_COVERAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.charge_head as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        t0.approved_amount as CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT,
        null,
        t0.charge_head as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE,
        null, null,
        t0.deduction as CLAIM_BENEFIT_HEAD__DEDUCTION_AMOUNT,
        t0.reason as CLAIM_BENEFIT_HEAD__DEDUCTION_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_copay_dtls_attrs_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_copay_dtls_attrs') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_claim_copay_dtls') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover),''), ''), nullif(nullif(trim(j3.claim_number),''), ''))) is not null

    union all

    -- branch 6: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        null,
        nullif('CLM-LOSS:' || nullif(trim(j6.claim_number),''), '') as LOSS_EVENT_BK,
        null, null,
        1 as __LNK_CLAIM_COVERAGE,
        1 as __LNK_CLAIM_LOSS_EVENT,
        null,
        t0.cover as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        t0.balance_sum_insured as AUG_CLAIM_BENEFIT_HEAD__BALANCE_SUM_INSURED,
        null,
        t0.percentage_payable as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PAYABLE_PERCENTAGE,
        null, null, null, null,
        t0.eligible_days_for_benefit as AUG_CLAIM_BENEFIT_HEAD__ELIGIBLE_BENEFIT_DAYS,
        null, null,
        t0.last_paid_emi_date as AUG_CLAIM_BENEFIT_HEAD__LAST_EMI_PAID_DATE,
        null,
        t0.coverage_nsbp as AUG_CLAIM_BENEFIT_HEAD__NSBP_COVERAGE_DETAIL,
        null,
        t0.others as AUG_CLAIM_BENEFIT_HEAD__OTHER_ATTRIBUTE_VALUE,
        t0.outstanding_loan_amount as AUG_CLAIM_BENEFIT_HEAD__OUTSTANDING_LOAN_AMOUNT,
        t0.per_sitting_charges as AUG_CLAIM_BENEFIT_HEAD__PER_SITTING_CHARGE_AMOUNT,
        null,
        t0.no_of_sittings as AUG_CLAIM_BENEFIT_HEAD__SITTING_COUNT,
        t0.percentage_of_si_payble as AUG_CLAIM_BENEFIT_HEAD__SUM_INSURED_PAYABLE_PERCENTAGE,
        null, null, null, null, null, null,
        t0.asst_reproductive_pro_tech as AUG_CLAIM_HEALTH_DETAIL__ASSISTED_REPRODUCTIVE_TECHNOLOGY_INDICATOR,
        t0.bmi as AUG_CLAIM_HEALTH_DETAIL__BODY_MASS_INDEX,
        t0.critical_illness_category as AUG_CLAIM_HEALTH_DETAIL__CRITICAL_ILLNESS_CATEGORY,
        t0.critical_illness_details as AUG_CLAIM_HEALTH_DETAIL__CRITICAL_ILLNESS_DESCRIPTION,
        null,
        t0.fitness_date as AUG_CLAIM_HEALTH_DETAIL__FITNESS_CERTIFICATION_DATE,
        t0.g_gravida_any_pregnancy_regardless_of_duration as AUG_CLAIM_HEALTH_DETAIL__GRAVIDA_COUNT,
        t0.type_of_hospitaizations as AUG_CLAIM_HEALTH_DETAIL__HOSPITALISATION_TYPE,
        t0.l_number_of_current_living_children as AUG_CLAIM_HEALTH_DETAIL__LIVING_CHILDREN_COUNT,
        t0.a_pregnancies_ending_in_spontaneous_abortion_or_therapeutic_abortion as AUG_CLAIM_HEALTH_DETAIL__PREGNANCY_TERMINATION_COUNT,
        t0.p_number_of_preterm_infants_born_after_20_weeks_and_before_37_weeks as AUG_CLAIM_HEALTH_DETAIL__PRETERM_BIRTH_COUNT,
        t0.provider_address as AUG_CLAIM_HEALTH_DETAIL__PROVIDER_ADDRESS,
        null,
        t0.no_of_surgeon_opinion_taken as AUG_CLAIM_HEALTH_DETAIL__SECOND_OPINION_COUNT,
        null,
        t0.type_severe_comorbidities as AUG_CLAIM_HEALTH_DETAIL__SEVERE_COMORBIDITY_DESCRIPTION,
        null, null, null,
        t0.mode_of_transportation as AUG_CLAIM_HEALTH_DETAIL__TRANSPORTATION_MODE,
        null,
        t0.disability_description as AUG_CLAIM_PA_DETAIL__DISABILITY_DESCRIPTION,
        t0.duration_of_disablment as AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION,
        null,
        t0.duration_of_leave as AUG_CLAIM_PA_DETAIL__LEAVE_DURATION,
        t0.leave_period_from as AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_FROM_DATE,
        t0.leave_period_to as AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_TO_DATE,
        t0.member_disability as AUG_CLAIM_PA_DETAIL__MEMBER_DISABILITY_INDICATOR,
        t0.type_of_disability_nsbp_iptt as AUG_CLAIM_PA_DETAIL__NSBP_IPTT_DISABILITY_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.cover as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        t0.approved_amount as CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT,
        null, null,
        t0.expected_amount as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
        null, null, null, null, null, null, null, null,
        t0.ayush_treatement as CLAIM_HEALTH_DETAIL__AYUSH_TREATMENT_INDICATOR,
        null, null, null, null, null, null, null, null, null,
        t0.service_provider as CLAIM_HEALTH_DETAIL__HOSPITAL_REFERENCE,
        null, null, null, null, null,
        t0.procedure_name_mhc as CLAIM_HEALTH_DETAIL__PROCEDURE_DESCRIPTION,
        null, null,
        t0.mode_of_treatment as CLAIM_HEALTH_DETAIL__TREATMENT_TYPE,
        null,
        t0.type_of_disability as CLAIM_PA_DETAIL__DISABILITY_TYPE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.cause_of_death as LOSS_EVENT_DETAIL__CAUSE_OF_LOSS,
        t0.date_of_injury as LOSS_EVENT_DETAIL__LOSS_DATE,
        null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr') }} j4 on j4.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (coalesce(nullif('CLM-LOSS:' || nullif(trim(j6.claim_number),''), ''), nullif('COV:' || nullif(trim(t0.cover),''), ''), nullif(nullif(trim(j3.claim_number),''), ''))) is not null

    union all

    -- branch 7: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover || '#' || 'MATERNITY_EXPENSE_MHC' as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null, null,
        t0.maternity_expense_mhc as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.claim_number),''), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover || '#' || 'MATERNITY_EXPENSE_SURR' as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null, null,
        t0.maternity_expense_surr as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.claim_number),''), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover || '#' || 'OUT_PATIENT_EXPENSES' as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null, null,
        t0.out_patient_expenses as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.claim_number),''), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_COVER_SET_ATTRIBUTE_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover || '#' || 'PHYSIOTHERAPY_CHARGES' as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null, null,
        t0.physiotherapy_charges as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_cover_set_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.claim_number),''), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.entity_head_code as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null,
        t0.entity_head_code as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE,
        null, null, null, null,
        t0.entity_head_name as CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claim_number),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j7.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.item_name as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null, null,
        t0.item_cost as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
        null, null, null,
        t0.item_name as CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_7391329b') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_e85c1c45') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_234ca173') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_109ef68e') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j7 on j7.KEY_HASH = j6.PARENT_KEY_HASH
    where (nullif(nullif(trim(j7.claim_number),''), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j5.claim_number),''), '') as CLAIM_BK,
        null, null, null,
        nullif('GSTIN:' || upper(nullif(trim(t0.gst_number),'')), '') as PARTY_BK,
        null, null, null, null,
        t0.benefit_code || '#' || t0.service_code as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null,
        t0.critical_ill_multiplier as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_MULTIPLIER,
        t0.benefit_percentage as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PAYABLE_PERCENTAGE,
        t0.start_date as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PERIOD_FROM_DATE,
        t0.end_date as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PERIOD_TO_DATE,
        t0.duration_in_weeks as AUG_CLAIM_BENEFIT_HEAD__CLAIMED_BENEFIT_WEEKS,
        t0.number_of_days as AUG_CLAIM_BENEFIT_HEAD__CLAIMED_NUMBER_OF_DAYS,
        null,
        t0.eligible_duration_in_weeks as AUG_CLAIM_BENEFIT_HEAD__ELIGIBLE_BENEFIT_WEEKS,
        t0.incurred_expenses as AUG_CLAIM_BENEFIT_HEAD__INCURRED_EXPENSE_AMOUNT,
        null,
        t0.maximum_number_of_weeks_approved as AUG_CLAIM_BENEFIT_HEAD__MAXIMUM_BENEFIT_WEEKS_APPROVED,
        null,
        t0.original_approved_amount as AUG_CLAIM_BENEFIT_HEAD__ORIGINAL_APPROVED_AMOUNT,
        null,
        t0.outstanding_loan_amount as AUG_CLAIM_BENEFIT_HEAD__OUTSTANDING_LOAN_AMOUNT,
        null,
        t0.old_approved_amount as AUG_CLAIM_BENEFIT_HEAD__PREVIOUS_APPROVED_AMOUNT,
        null, null,
        t0.system_calculated_amount as AUG_CLAIM_BENEFIT_HEAD__SYSTEM_CALCULATED_AMOUNT,
        t0.total_benefit_approved as AUG_CLAIM_BENEFIT_HEAD__TOTAL_BENEFIT_APPROVED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.duration_of_disablement as AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION,
        t0.duration_of_disablity_in_weeks as AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION_WEEKS,
        null, null, null, null, null,
        t0.bill_number || '#' || t0.service_code as AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        t0.additional_bill_discount as AUG_CLAIM_PROVIDER_BILLING__ADDITIONAL_BILL_DISCOUNT_AMOUNT,
        t0.approved_quantity as AUG_CLAIM_PROVIDER_BILLING__APPROVED_QUANTITY,
        t0.quantity as AUG_CLAIM_PROVIDER_BILLING__BILLED_QUANTITY,
        t0.discount_amount as AUG_CLAIM_PROVIDER_BILLING__BILL_DISCOUNT_AMOUNT,
        t0.gst_amount as AUG_CLAIM_PROVIDER_BILLING__BILL_GST_AMOUNT,
        t0.hospital_gst_amount as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_GST_AMOUNT,
        t0.hospital_item_code as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_ITEM_CODE,
        t0.hospital_item_description as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_ITEM_DESCRIPTION,
        t0.invoice_raised_against_bagic as AUG_CLAIM_PROVIDER_BILLING__INVOICE_RAISED_AGAINST_INSURER_INDICATOR,
        t0.manual_rejection as AUG_CLAIM_PROVIDER_BILLING__MANUAL_REJECTION_INDICATOR,
        t0.nonmedical_expenses as AUG_CLAIM_PROVIDER_BILLING__NON_MEDICAL_EXPENSE_AMOUNT,
        t0.nonmedical_items as AUG_CLAIM_PROVIDER_BILLING__NON_MEDICAL_ITEMS,
        t0.no_of_sittings as AUG_CLAIM_PROVIDER_BILLING__NUMBER_OF_SITTINGS,
        t0.override_remarks as AUG_CLAIM_PROVIDER_BILLING__OVERRIDE_REMARKS,
        t0.payment_received as AUG_CLAIM_PROVIDER_BILLING__PAYMENT_RECEIVED_INDICATOR,
        t0.per_sitting_charges as AUG_CLAIM_PROVIDER_BILLING__PER_SITTING_CHARGE_AMOUNT,
        t0.pharmacy_return as AUG_CLAIM_PROVIDER_BILLING__PHARMACY_RETURN_AMOUNT,
        t0.pharmacy_return_deducted as AUG_CLAIM_PROVIDER_BILLING__PHARMACY_RETURN_DEDUCTED_AMOUNT,
        t0.reasonable_customer_charges as AUG_CLAIM_PROVIDER_BILLING__REASONABLE_AND_CUSTOMARY_CHARGE_AMOUNT,
        t0.r_c_deduction_remarks as AUG_CLAIM_PROVIDER_BILLING__REASONABLE_AND_CUSTOMARY_DEDUCTION_REMARKS,
        t0.service_date as AUG_CLAIM_PROVIDER_BILLING__SERVICE_RENDERED_DATE,
        t0.tariff_indc_type as AUG_CLAIM_PROVIDER_BILLING__TARIFF_INDICATOR_TYPE,
        t0.unit as AUG_CLAIM_PROVIDER_BILLING__UNIT_OF_MEASURE,
        t0.unit_type as AUG_CLAIM_PROVIDER_BILLING__UNIT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.service_code as AUG_PROVIDER_TARIFF__SERVICE_CODE_CK,
        t0.i3_tariff_price as AUG_PROVIDER_TARIFF__I3_TARIFF_PRICE,
        t0.i3_tariff_remarks as AUG_PROVIDER_TARIFF__I3_TARIFF_REMARKS,
        t0.service_type_code as AUG_PROVIDER_TARIFF__SERVICE_TYPE_CODE,
        t0.service_type_description as AUG_PROVIDER_TARIFF__SERVICE_TYPE_DESCRIPTION,
        t0.deductible_consumed as CLAIM_ASSESSMENT_SUMMARY__DEDUCTIBLE_APPLIED,
        t0.benefit_code || '#' || t0.service_code as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        t0.approved_amount as CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT,
        t0.eligible_amount as CLAIM_BENEFIT_HEAD__ASSESSED_AMOUNT,
        null, null, null, null, null, null,
        t0.benefit_status as CLAIM_BENEFIT_HEAD__STATUS,
        null,
        t0.time_of_admission as CLAIM_HEALTH_DETAIL__ADMISSION_TIME,
        null, null, null, null, null, null, null,
        t0.time_of_discharge as CLAIM_HEALTH_DETAIL__DISCHARGE_TIME,
        null, null, null, null, null, null, null,
        t0.provider_discount as CLAIM_HEALTH_DETAIL__NETWORK_DISCOUNT_AMOUNT,
        null, null,
        t0.room_type as CLAIM_HEALTH_DETAIL__ROOM_CATEGORY,
        null, null,
        t0.tariff_applicable as CLAIM_NETWORK_VERIFICATION__TARIFF_APPLICABLE_INDICATOR,
        null,
        t0.no_of_weeks_of_benefit_paid as CLAIM_PA_DETAIL__NUMBER_OF_WEEKS,
        t0.bill_number || '#' || t0.service_code as CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
        t0.billed_amount as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
        t0.bill_number as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
        t0.rejected_reason as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
        t0.rejected_amount as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.service_code as PROVIDER_TARIFF__SERVICE_CODE_CK,
        t0.tariff_amount as PROVIDER_TARIFF__PACKAGE_RATE,
        t0.service_code as PROVIDER_TARIFF__SERVICE_CODE,
        t0.service_name as PROVIDER_TARIFF__SERVICE_DESCRIPTION,
        t0.tariff_rate_per_unit as PROVIDER_TARIFF__TARIFF_RATE,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_d3003ace') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_109ef68e') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif('GSTIN:' || upper(nullif(trim(t0.gst_number),'')), ''), nullif(nullif(trim(j5.claim_number),''), ''))) is not null

    union all

    -- branch 14: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j5.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.benefit_code as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
        null, null, null, null,
        t0.copay_amount as CLAIM_BENEFIT_HEAD__CO_PAY_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_d3003ace') }} t0
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_109ef68e') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_list_of_covers') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.claim_number),''), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_MEMBERS_FOLLOW_UP_REPORT_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_FOLLOW_UP_LOG.Entry Timestamp=coalesce(DATE,'') || '#' || coalesce(TIME,'')
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'coalesce(DATE,'''') || ''#'' || coalesce(TIME,'''')' as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK,
        t0.effective_date as AUG_POLICY_FOLLOW_UP_LOG__EFFECTIVE_DATE,
        t0.date as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_DATE,
        t0.remarks as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_REMARKS,
        t0.time as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIME,
        t0.endorsement_number_claim_number as AUG_POLICY_FOLLOW_UP_LOG__RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE,
        t0.status as AUG_POLICY_FOLLOW_UP_LOG__STATUS_CODE,
        t0.substatus as AUG_POLICY_FOLLOW_UP_LOG__SUB_STATUS_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_follow_up_report_attrs_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_follow_up_report_attrs') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_follow_up_report') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

)

select
    CLAIM_BK,
    COVERAGE_BK,
    DOCUMENT_BK,
    LOSS_EVENT_BK,
    PARTY_BK,
    POLICY_BK,
    __LNK_CLAIM_COVERAGE,
    __LNK_CLAIM_LOSS_EVENT,
    first_value(AUG_CLAIM_ASSESSMENT_SUMMARY__AUTO_ADJUDICATION_ENGINE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_ASSESSMENT_SUMMARY__AUTO_ADJUDICATION_ENGINE_INDICATOR,
    AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
    first_value(AUG_CLAIM_BENEFIT_HEAD__BALANCE_SUM_INSURED) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__BALANCE_SUM_INSURED,
    first_value(AUG_CLAIM_BENEFIT_HEAD__BENEFIT_MULTIPLIER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_MULTIPLIER,
    first_value(AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PAYABLE_PERCENTAGE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PAYABLE_PERCENTAGE,
    first_value(AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PERIOD_FROM_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PERIOD_FROM_DATE,
    first_value(AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PERIOD_TO_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__BENEFIT_PERIOD_TO_DATE,
    first_value(AUG_CLAIM_BENEFIT_HEAD__CLAIMED_BENEFIT_WEEKS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__CLAIMED_BENEFIT_WEEKS,
    first_value(AUG_CLAIM_BENEFIT_HEAD__CLAIMED_NUMBER_OF_DAYS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__CLAIMED_NUMBER_OF_DAYS,
    first_value(AUG_CLAIM_BENEFIT_HEAD__ELIGIBLE_BENEFIT_DAYS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__ELIGIBLE_BENEFIT_DAYS,
    first_value(AUG_CLAIM_BENEFIT_HEAD__ELIGIBLE_BENEFIT_WEEKS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__ELIGIBLE_BENEFIT_WEEKS,
    first_value(AUG_CLAIM_BENEFIT_HEAD__INCURRED_EXPENSE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__INCURRED_EXPENSE_AMOUNT,
    first_value(AUG_CLAIM_BENEFIT_HEAD__LAST_EMI_PAID_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__LAST_EMI_PAID_DATE,
    first_value(AUG_CLAIM_BENEFIT_HEAD__MAXIMUM_BENEFIT_WEEKS_APPROVED) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__MAXIMUM_BENEFIT_WEEKS_APPROVED,
    first_value(AUG_CLAIM_BENEFIT_HEAD__NSBP_COVERAGE_DETAIL) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__NSBP_COVERAGE_DETAIL,
    first_value(AUG_CLAIM_BENEFIT_HEAD__ORIGINAL_APPROVED_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__ORIGINAL_APPROVED_AMOUNT,
    first_value(AUG_CLAIM_BENEFIT_HEAD__OTHER_ATTRIBUTE_VALUE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__OTHER_ATTRIBUTE_VALUE,
    first_value(AUG_CLAIM_BENEFIT_HEAD__OUTSTANDING_LOAN_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__OUTSTANDING_LOAN_AMOUNT,
    first_value(AUG_CLAIM_BENEFIT_HEAD__PER_SITTING_CHARGE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__PER_SITTING_CHARGE_AMOUNT,
    first_value(AUG_CLAIM_BENEFIT_HEAD__PREVIOUS_APPROVED_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__PREVIOUS_APPROVED_AMOUNT,
    first_value(AUG_CLAIM_BENEFIT_HEAD__SITTING_COUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__SITTING_COUNT,
    first_value(AUG_CLAIM_BENEFIT_HEAD__SUM_INSURED_PAYABLE_PERCENTAGE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__SUM_INSURED_PAYABLE_PERCENTAGE,
    first_value(AUG_CLAIM_BENEFIT_HEAD__SYSTEM_CALCULATED_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__SYSTEM_CALCULATED_AMOUNT,
    first_value(AUG_CLAIM_BENEFIT_HEAD__TOTAL_BENEFIT_APPROVED_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_BENEFIT_HEAD__TOTAL_BENEFIT_APPROVED_AMOUNT,
    first_value(AUG_CLAIM_FRAUD__SUSPICIOUS_CHECK_BYPASS_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_FRAUD__SUSPICIOUS_CHECK_BYPASS_INDICATOR,
    first_value(AUG_CLAIM_HEADER__CLAIM_SUB_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__CLAIM_SUB_TYPE,
    first_value(AUG_CLAIM_HEADER__REGISTRATION_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEADER__REGISTRATION_TYPE,
    first_value(AUG_CLAIM_HEALTH_DETAIL__ADMISSION_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__ADMISSION_TYPE,
    first_value(AUG_CLAIM_HEALTH_DETAIL__ASSISTED_REPRODUCTIVE_TECHNOLOGY_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__ASSISTED_REPRODUCTIVE_TECHNOLOGY_INDICATOR,
    first_value(AUG_CLAIM_HEALTH_DETAIL__BODY_MASS_INDEX) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__BODY_MASS_INDEX,
    first_value(AUG_CLAIM_HEALTH_DETAIL__CRITICAL_ILLNESS_CATEGORY) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__CRITICAL_ILLNESS_CATEGORY,
    first_value(AUG_CLAIM_HEALTH_DETAIL__CRITICAL_ILLNESS_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__CRITICAL_ILLNESS_DESCRIPTION,
    first_value(AUG_CLAIM_HEALTH_DETAIL__EXPECTED_ADMISSION_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__EXPECTED_ADMISSION_DATE,
    first_value(AUG_CLAIM_HEALTH_DETAIL__FITNESS_CERTIFICATION_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__FITNESS_CERTIFICATION_DATE,
    first_value(AUG_CLAIM_HEALTH_DETAIL__GRAVIDA_COUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__GRAVIDA_COUNT,
    first_value(AUG_CLAIM_HEALTH_DETAIL__HOSPITALISATION_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__HOSPITALISATION_TYPE,
    first_value(AUG_CLAIM_HEALTH_DETAIL__LIVING_CHILDREN_COUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__LIVING_CHILDREN_COUNT,
    first_value(AUG_CLAIM_HEALTH_DETAIL__PREGNANCY_TERMINATION_COUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__PREGNANCY_TERMINATION_COUNT,
    first_value(AUG_CLAIM_HEALTH_DETAIL__PRETERM_BIRTH_COUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__PRETERM_BIRTH_COUNT,
    first_value(AUG_CLAIM_HEALTH_DETAIL__PROVIDER_ADDRESS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__PROVIDER_ADDRESS,
    first_value(AUG_CLAIM_HEALTH_DETAIL__RADIOLOGIST_DETAIL) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__RADIOLOGIST_DETAIL,
    first_value(AUG_CLAIM_HEALTH_DETAIL__SECOND_OPINION_COUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__SECOND_OPINION_COUNT,
    first_value(AUG_CLAIM_HEALTH_DETAIL__SERVICE_RENDERED_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__SERVICE_RENDERED_DATE,
    first_value(AUG_CLAIM_HEALTH_DETAIL__SEVERE_COMORBIDITY_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__SEVERE_COMORBIDITY_DESCRIPTION,
    first_value(AUG_CLAIM_HEALTH_DETAIL__SYSTEM_OF_MEDICINE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__SYSTEM_OF_MEDICINE,
    first_value(AUG_CLAIM_HEALTH_DETAIL__TEST_PACKAGE_DETAIL) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__TEST_PACKAGE_DETAIL,
    first_value(AUG_CLAIM_HEALTH_DETAIL__TOTAL_CO_PAY_AND_DEDUCTIBLE_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__TOTAL_CO_PAY_AND_DEDUCTIBLE_AMOUNT,
    first_value(AUG_CLAIM_HEALTH_DETAIL__TRANSPORTATION_MODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__TRANSPORTATION_MODE,
    first_value(AUG_CLAIM_HEALTH_DETAIL__TREATMENT_SUB_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_HEALTH_DETAIL__TREATMENT_SUB_TYPE,
    first_value(AUG_CLAIM_PA_DETAIL__DISABILITY_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__DISABILITY_DESCRIPTION,
    first_value(AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION,
    first_value(AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION_WEEKS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION_WEEKS,
    first_value(AUG_CLAIM_PA_DETAIL__LEAVE_DURATION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__LEAVE_DURATION,
    first_value(AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_FROM_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_FROM_DATE,
    first_value(AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_TO_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_TO_DATE,
    first_value(AUG_CLAIM_PA_DETAIL__MEMBER_DISABILITY_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__MEMBER_DISABILITY_INDICATOR,
    first_value(AUG_CLAIM_PA_DETAIL__NSBP_IPTT_DISABILITY_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PA_DETAIL__NSBP_IPTT_DISABILITY_TYPE,
    AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
    first_value(AUG_CLAIM_PROVIDER_BILLING__ADDITIONAL_BILL_DISCOUNT_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__ADDITIONAL_BILL_DISCOUNT_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__APPROVED_QUANTITY) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__APPROVED_QUANTITY,
    first_value(AUG_CLAIM_PROVIDER_BILLING__BILLED_QUANTITY) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__BILLED_QUANTITY,
    first_value(AUG_CLAIM_PROVIDER_BILLING__BILL_DISCOUNT_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__BILL_DISCOUNT_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__BILL_GST_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__BILL_GST_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_GST_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_GST_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_ITEM_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_ITEM_CODE,
    first_value(AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_ITEM_DESCRIPTION) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__HOSPITAL_ITEM_DESCRIPTION,
    first_value(AUG_CLAIM_PROVIDER_BILLING__INVOICE_RAISED_AGAINST_INSURER_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__INVOICE_RAISED_AGAINST_INSURER_INDICATOR,
    first_value(AUG_CLAIM_PROVIDER_BILLING__MANUAL_REJECTION_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__MANUAL_REJECTION_INDICATOR,
    first_value(AUG_CLAIM_PROVIDER_BILLING__NON_MEDICAL_EXPENSE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__NON_MEDICAL_EXPENSE_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__NON_MEDICAL_ITEMS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__NON_MEDICAL_ITEMS,
    first_value(AUG_CLAIM_PROVIDER_BILLING__NUMBER_OF_SITTINGS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__NUMBER_OF_SITTINGS,
    first_value(AUG_CLAIM_PROVIDER_BILLING__OVERRIDE_REMARKS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__OVERRIDE_REMARKS,
    first_value(AUG_CLAIM_PROVIDER_BILLING__PAYMENT_RECEIVED_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__PAYMENT_RECEIVED_INDICATOR,
    first_value(AUG_CLAIM_PROVIDER_BILLING__PER_SITTING_CHARGE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__PER_SITTING_CHARGE_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__PHARMACY_RETURN_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__PHARMACY_RETURN_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__PHARMACY_RETURN_DEDUCTED_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__PHARMACY_RETURN_DEDUCTED_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__REASONABLE_AND_CUSTOMARY_CHARGE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__REASONABLE_AND_CUSTOMARY_CHARGE_AMOUNT,
    first_value(AUG_CLAIM_PROVIDER_BILLING__REASONABLE_AND_CUSTOMARY_DEDUCTION_REMARKS) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__REASONABLE_AND_CUSTOMARY_DEDUCTION_REMARKS,
    first_value(AUG_CLAIM_PROVIDER_BILLING__SERVICE_RENDERED_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__SERVICE_RENDERED_DATE,
    first_value(AUG_CLAIM_PROVIDER_BILLING__TARIFF_INDICATOR_TYPE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__TARIFF_INDICATOR_TYPE,
    first_value(AUG_CLAIM_PROVIDER_BILLING__UNIT_OF_MEASURE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__UNIT_OF_MEASURE,
    first_value(AUG_CLAIM_PROVIDER_BILLING__UNIT_TYPE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PROVIDER_BILLING__UNIT_TYPE,
    first_value(AUG_CLAIM_QUALITY_AUDIT__QUALITY_CHECK_REMARKS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_QUALITY_AUDIT__QUALITY_CHECK_REMARKS,
    first_value(AUG_CLAIM_QUALITY_AUDIT__SPECIAL_AUTHORITY_OBSERVATION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_QUALITY_AUDIT__SPECIAL_AUTHORITY_OBSERVATION,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_ADJUSTED_AGAINST_CLAIM_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_ADJUSTED_AGAINST_CLAIM_REFERENCE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_ADJUSTED_FROM_OTHER_CLAIM_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_ADJUSTED_FROM_OTHER_CLAIM_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_DETAIL_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_DETAIL_DESCRIPTION,
    first_value(AUG_CLAIM_TPA_INTERACTION__TPA_BILLING_DETAIL) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_TPA_INTERACTION__TPA_BILLING_DETAIL,
    first_value(AUG_CLAIM_TPA_INTERACTION__TPA_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_TPA_INTERACTION__TPA_NAME,
    first_value(AUG_DOCUMENT_DEFINITION__COURIER_PROOF_OF_DELIVERY_NUMBER) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__COURIER_PROOF_OF_DELIVERY_NUMBER,
    first_value(AUG_DOCUMENT_DEFINITION__SECONDARY_DOCUMENT_TYPE) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__SECONDARY_DOCUMENT_TYPE,
    first_value(AUG_DOCUMENT_DEFINITION__SENDER_DESPATCH_REFERENCE_NUMBER) ignore nulls over (partition by DOCUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_DOCUMENT_DEFINITION__SENDER_DESPATCH_REFERENCE_NUMBER,
    AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK,
    first_value(AUG_POLICY_FOLLOW_UP_LOG__EFFECTIVE_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_FOLLOW_UP_LOG__EFFECTIVE_DATE,
    first_value(AUG_POLICY_FOLLOW_UP_LOG__ENTRY_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_DATE,
    first_value(AUG_POLICY_FOLLOW_UP_LOG__ENTRY_REMARKS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_REMARKS,
    first_value(AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIME) ignore nulls over (partition by POLICY_BK, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIME,
    first_value(AUG_POLICY_FOLLOW_UP_LOG__RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_FOLLOW_UP_LOG__RELATED_ENDORSEMENT_OR_CLAIM_REFERENCE,
    first_value(AUG_POLICY_FOLLOW_UP_LOG__STATUS_CODE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_FOLLOW_UP_LOG__STATUS_CODE,
    first_value(AUG_POLICY_FOLLOW_UP_LOG__SUB_STATUS_CODE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_FOLLOW_UP_LOG__ENTRY_TIMESTAMP_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_FOLLOW_UP_LOG__SUB_STATUS_CODE,
    AUG_PROVIDER_TARIFF__SERVICE_CODE_CK,
    first_value(AUG_PROVIDER_TARIFF__I3_TARIFF_PRICE) ignore nulls over (partition by PARTY_BK, AUG_PROVIDER_TARIFF__SERVICE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROVIDER_TARIFF__I3_TARIFF_PRICE,
    first_value(AUG_PROVIDER_TARIFF__I3_TARIFF_REMARKS) ignore nulls over (partition by PARTY_BK, AUG_PROVIDER_TARIFF__SERVICE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROVIDER_TARIFF__I3_TARIFF_REMARKS,
    first_value(AUG_PROVIDER_TARIFF__SERVICE_TYPE_CODE) ignore nulls over (partition by PARTY_BK, AUG_PROVIDER_TARIFF__SERVICE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROVIDER_TARIFF__SERVICE_TYPE_CODE,
    first_value(AUG_PROVIDER_TARIFF__SERVICE_TYPE_DESCRIPTION) ignore nulls over (partition by PARTY_BK, AUG_PROVIDER_TARIFF__SERVICE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROVIDER_TARIFF__SERVICE_TYPE_DESCRIPTION,
    first_value(CLAIM_ASSESSMENT_SUMMARY__DEDUCTIBLE_APPLIED) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_ASSESSMENT_SUMMARY__DEDUCTIBLE_APPLIED,
    CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK,
    first_value(CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT,
    first_value(CLAIM_BENEFIT_HEAD__ASSESSED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__ASSESSED_AMOUNT,
    first_value(CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE,
    first_value(CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT,
    first_value(CLAIM_BENEFIT_HEAD__CO_PAY_APPLIED) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__CO_PAY_APPLIED,
    first_value(CLAIM_BENEFIT_HEAD__DEDUCTION_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__DEDUCTION_AMOUNT,
    first_value(CLAIM_BENEFIT_HEAD__DEDUCTION_REASON) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__DEDUCTION_REASON,
    first_value(CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION,
    first_value(CLAIM_BENEFIT_HEAD__STATUS) ignore nulls over (partition by CLAIM_BK, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_BENEFIT_HEAD__STATUS,
    first_value(CLAIM_HEALTH_DETAIL__ADMISSION_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__ADMISSION_DATE,
    first_value(CLAIM_HEALTH_DETAIL__ADMISSION_TIME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__ADMISSION_TIME,
    first_value(CLAIM_HEALTH_DETAIL__AILMENT_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__AILMENT_DESCRIPTION,
    first_value(CLAIM_HEALTH_DETAIL__AYUSH_TREATMENT_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__AYUSH_TREATMENT_INDICATOR,
    first_value(CLAIM_HEALTH_DETAIL__CASHLESS_AUTHORISATION_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__CASHLESS_AUTHORISATION_NUMBER,
    first_value(CLAIM_HEALTH_DETAIL__DEDUCTIBLE_DETAIL) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__DEDUCTIBLE_DETAIL,
    first_value(CLAIM_HEALTH_DETAIL__DIAGNOSIS_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__DIAGNOSIS_CODE,
    first_value(CLAIM_HEALTH_DETAIL__DISALLOWED_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__DISALLOWED_AMOUNT,
    first_value(CLAIM_HEALTH_DETAIL__DISCHARGE_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__DISCHARGE_DATE,
    first_value(CLAIM_HEALTH_DETAIL__DISCHARGE_TIME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__DISCHARGE_TIME,
    first_value(CLAIM_HEALTH_DETAIL__ELIGIBLE_ROOM_CATEGORY) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__ELIGIBLE_ROOM_CATEGORY,
    first_value(CLAIM_HEALTH_DETAIL__ELIGIBLE_ROOM_RENT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__ELIGIBLE_ROOM_RENT,
    first_value(CLAIM_HEALTH_DETAIL__EXPECTED_DISCHARGE_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__EXPECTED_DISCHARGE_DATE,
    first_value(CLAIM_HEALTH_DETAIL__HOSPITAL_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__HOSPITAL_REFERENCE,
    first_value(CLAIM_HEALTH_DETAIL__ICD_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__ICD_CODE,
    first_value(CLAIM_HEALTH_DETAIL__IPD_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__IPD_NUMBER,
    first_value(CLAIM_HEALTH_DETAIL__LENGTH_OF_STAY) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__LENGTH_OF_STAY,
    first_value(CLAIM_HEALTH_DETAIL__NETWORK_DISCOUNT_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__NETWORK_DISCOUNT_AMOUNT,
    first_value(CLAIM_HEALTH_DETAIL__PROCEDURE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__PROCEDURE_CODE,
    first_value(CLAIM_HEALTH_DETAIL__PROCEDURE_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__PROCEDURE_DESCRIPTION,
    first_value(CLAIM_HEALTH_DETAIL__ROOM_CATEGORY) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__ROOM_CATEGORY,
    first_value(CLAIM_HEALTH_DETAIL__TREATING_DOCTOR_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__TREATING_DOCTOR_NAME,
    first_value(CLAIM_HEALTH_DETAIL__TREATMENT_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEALTH_DETAIL__TREATMENT_TYPE,
    first_value(CLAIM_NETWORK_VERIFICATION__TARIFF_APPLICABLE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_NETWORK_VERIFICATION__TARIFF_APPLICABLE_INDICATOR,
    first_value(CLAIM_PA_DETAIL__DISABILITY_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PA_DETAIL__DISABILITY_TYPE,
    first_value(CLAIM_PA_DETAIL__NUMBER_OF_WEEKS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PA_DETAIL__NUMBER_OF_WEEKS,
    CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK,
    first_value(CLAIM_PROVIDER_BILLING__BILLED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__BILLED_AMOUNT,
    first_value(CLAIM_PROVIDER_BILLING__BILL_NUMBER) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__BILL_NUMBER,
    first_value(CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__DISALLOWANCE_REASON,
    first_value(CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_PROVIDER_BILLING__BILL_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PROVIDER_BILLING__DISALLOWED_AMOUNT,
    first_value(CLAIM_REPUDIATION__REPUDIATION_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_REPUDIATION__REPUDIATION_REASON,
    first_value(CLAIM_TPA_INTERACTION__AUTHORISATION_MESSAGE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_TPA_INTERACTION__AUTHORISATION_MESSAGE,
    first_value(CLAIM_TPA_INTERACTION__DENIAL_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_TPA_INTERACTION__DENIAL_INDICATOR,
    first_value(CLAIM_TPA_INTERACTION__DENIAL_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_TPA_INTERACTION__DENIAL_REASON,
    first_value(CLAIM_TPA_INTERACTION__TPA_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_TPA_INTERACTION__TPA_REFERENCE,
    first_value(LOSS_EVENT_DETAIL__CAUSE_OF_LOSS) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__CAUSE_OF_LOSS,
    first_value(LOSS_EVENT_DETAIL__LOSS_DATE) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__LOSS_DATE,
    first_value(LOSS_EVENT_DETAIL__LOSS_DESCRIPTION) ignore nulls over (partition by LOSS_EVENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOSS_EVENT_DETAIL__LOSS_DESCRIPTION,
    POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK,
    first_value(POLICY_CLAUSE_ATTACHED__CLAUSE_CODE) ignore nulls over (partition by POLICY_BK, POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE,
    first_value(POLICY_CLAUSE_ATTACHED__CLAUSE_TITLE) ignore nulls over (partition by POLICY_BK, POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLAUSE_ATTACHED__CLAUSE_TITLE,
    PROVIDER_TARIFF__SERVICE_CODE_CK,
    first_value(PROVIDER_TARIFF__PACKAGE_RATE) ignore nulls over (partition by PARTY_BK, PROVIDER_TARIFF__SERVICE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROVIDER_TARIFF__PACKAGE_RATE,
    first_value(PROVIDER_TARIFF__SERVICE_CODE) ignore nulls over (partition by PARTY_BK, PROVIDER_TARIFF__SERVICE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROVIDER_TARIFF__SERVICE_CODE,
    first_value(PROVIDER_TARIFF__SERVICE_DESCRIPTION) ignore nulls over (partition by PARTY_BK, PROVIDER_TARIFF__SERVICE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROVIDER_TARIFF__SERVICE_DESCRIPTION,
    first_value(PROVIDER_TARIFF__TARIFF_RATE) ignore nulls over (partition by PARTY_BK, PROVIDER_TARIFF__SERVICE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROVIDER_TARIFF__TARIFF_RATE
from merged
