-- CENTRAL VIEW v15_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_POLICY_AND_CLAIM_HISTORY
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_POLICY_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO
--   MAXI_HLTH_UWR_VW_DATA_POLICY_PAYMENT_CYCLE_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_POLICY_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_POLICY_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ACCOUNT_BALANCE
--   SAT_ACCOUNT_DEFINITION
--   SAT_ASSESSMENT_FRAUD_INVESTIGATION
--   SAT_AUG_ACCOUNT_DEFINITION
--   SAT_AUG_PARTY_POLICY_HISTORY
--   SAT_AUG_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_AUG_POLICY_HEADER
--   SAT_AUG_POLICY_INSTALMENT_SCHEDULE
--   SAT_AUG_POLICY_PORTABILITY_MIGRATION
--   SAT_AUG_POLICY_PREMIUM_HEAD
--   SAT_AUG_RISK_HEALTH_MEMBER_COVERAGE
--   SAT_AUG_RISK_HEALTH_MEMBER_MEDICAL
--   SAT_LNK_ROLE_NOMINEE_BENEFICIARY
--   SAT_ORG_UNIT_DEFINITION
--   SAT_PARTY_CLAIM_HISTORY
--   SAT_PARTY_KYC_REFERENCE
--   SAT_PARTY_POLICY_HISTORY
--   SAT_POLICY_CLASSIFICATION
--   SAT_POLICY_GROUP
--   SAT_POLICY_HEADER
--   SAT_POLICY_INSTALMENT_SCHEDULE
--   SAT_POLICY_PREMIUM_SUMMARY
--   SAT_POLICY_TAX_BREAKUP
--   SAT_PRODUCT_UW_RULE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_PARTY
--   LNK_FINTXN_POLICY
--   LNK_ORG_UNIT_LOCATION
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_LOCATION
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('INV:' || nullif(trim(t0.investigation_id),''), '') as ASSESSMENT_BK,
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as FINANCIAL_ACCOUNT_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as LOCATION_BK,
        nullif('TEAM:' || upper(nullif(trim(t0.scanning_team),'')), '') as ORG_UNIT_BK,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_FINTXN_PARTY,
        cast(null as number) as __LNK_FINTXN_POLICY,
        cast(null as number) as __LNK_ORG_UNIT_LOCATION,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_PROPOSAL_POLICY,
        cast(null as number) as __LNK_PROPOSAL_PRODUCT,
        cast(null as varchar) as ACCOUNT_BALANCE__OPENING_BALANCE,
        cast(null as varchar) as ACCOUNT_DEFINITION__ACCOUNT_CATEGORY,
        cast(null as varchar) as ACCOUNT_DEFINITION__ACCOUNT_TYPE,
        t0.investigation_reports_details as ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY,
        cast(null as varchar) as ASSESSMENT_FRAUD_INVESTIGATION__MISREPRESENTATION_INDICATOR,
        t0.investigating_triggers as ASSESSMENT_FRAUD_INVESTIGATION__TRIGGER_REASON,
        cast(null as varchar) as AUG_ACCOUNT_DEFINITION__LOAN_TENURE_YEARS,
        cast(null as varchar) as AUG_PARTY_POLICY_HISTORY__OTHER_HELD_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICABLE_TO_OTHER_MEMBERS_INDICATOR,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICATION_LEVEL,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__LOADING_WAIVER_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__OTHER_REMARKS,
        t0.policy_holder_name as AUG_POLICY_HEADER__POLICYHOLDER_NAME,
        cast(null as varchar) as AUG_POLICY_HEADER__PREMIUM_PAYER_NAME,
        cast(null as varchar) as AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        cast(null as varchar) as AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_INVOICE_NUMBER,
        cast(null as varchar) as AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_PERIOD_END_DATE,
        t0.policy_vintage_dependent as AUG_POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED_DEPENDENT,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURANCE_TYPE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_CODE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INTERNATIONAL_SUM_INSURED,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PRO_RATA_AMOUNT,
        cast(null as varchar) as AUG_RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK,
        cast(null as varchar) as AUG_RISK_HEALTH_MEMBER_COVERAGE__ELIGIBLE_SUM_INSURED,
        cast(null as varchar) as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        cast(null as varchar) as AUG_RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        cast(null as varchar) as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DOSAGE,
        cast(null as varchar) as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DURATION,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__GUARDIAN_RELATIONSHIP,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINATION_PERCENTAGE,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_DATE_OF_BIRTH,
        cast(null as varchar) as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_INDICATOR,
        cast(null as varchar) as ORG_UNIT_DEFINITION__FUNCTIONAL_TYPE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__GST_REGISTRATION_NUMBER,
        t0.scanning_team as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ZONE_NAME,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__CLAIM_RATIO,
        cast(null as varchar) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        cast(null as varchar) as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        cast(null as varchar) as PARTY_KYC_REFERENCE__VERIFICATION_STATUS,
        t0.first_inception_date as PARTY_POLICY_HISTORY__FIRST_POLICY_DATE,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        cast(null as varchar) as POLICY_GROUP__EMPLOYER_CONTRIBUTION_PERCENTAGE,
        cast(null as varchar) as POLICY_GROUP__GROUP_SIZE,
        t0.group_policy_type as POLICY_GROUP__GROUP_TYPE,
        t0.group_policy_number as POLICY_GROUP__MASTER_POLICY_NUMBER,
        cast(null as varchar) as POLICY_GROUP__MEMBER_ENROLMENT_BASIS,
        cast(null as varchar) as POLICY_HEADER__CO_INSURANCE_INDICATOR,
        cast(null as varchar) as POLICY_HEADER__CURRENCY_CODE,
        cast(null as varchar) as POLICY_HEADER__ISSUING_CHANNEL_REFERENCE,
        cast(null as varchar) as POLICY_HEADER__LINE_OF_BUSINESS,
        cast(null as varchar) as POLICY_HEADER__NUMBER_OF_LIVES_COVERED,
        cast(null as varchar) as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        cast(null as varchar) as POLICY_HEADER__POLICY_NUMBER,
        cast(null as varchar) as POLICY_HEADER__POLICY_REMARKS,
        cast(null as varchar) as POLICY_HEADER__POLICY_STATUS,
        cast(null as varchar) as POLICY_HEADER__POLICY_SUB_STATUS,
        cast(null as varchar) as POLICY_HEADER__POLICY_TERM,
        cast(null as varchar) as POLICY_HEADER__POLICY_TERM_DAYS,
        cast(null as varchar) as POLICY_HEADER__POLICY_TYPE,
        cast(null as varchar) as POLICY_HEADER__PREMIUM_FREQUENCY,
        cast(null as varchar) as POLICY_HEADER__PREMIUM_PAYER_REFERENCE,
        t0.risk_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.risk_inception_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        cast(null as varchar) as POLICY_HEADER__RISK_START_TIME,
        cast(null as varchar) as POLICY_HEADER__SUM_INSURED_TOTAL,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__AUTO_DEBIT_INDICATOR,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_STATUS,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
        cast(null as varchar) as POLICY_INSTALMENT_SCHEDULE__PAID_DATE,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__INSTALMENT_INDICATOR,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__LOYALTY_DISCOUNT_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED,
        cast(null as varchar) as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        t0.bagic_gst as POLICY_TAX_BREAKUP__GSTIN_OF_INSURER,
        cast(null as varchar) as POLICY_TAX_BREAKUP__IGST_AMOUNT,
        cast(null as varchar) as POLICY_TAX_BREAKUP__SGST_AMOUNT,
        cast(null as varchar) as PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as PRODUCT_UW_RULE__TRIGGER_CONDITION,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('INV:' || nullif(trim(t0.investigation_id),''), ''), nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), ''), nullif('TEAM:' || upper(nullif(trim(t0.scanning_team),'')), ''), nullif(nullif(trim(j2.pol_policy_number),''), ''))) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null, null,
        nullif('TEAM:' || upper(nullif(trim(t0.team_name),'')), '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.team_name as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('TEAM:' || upper(nullif(trim(t0.team_name),'')), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(t0.branch_code1, '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.branch_gst_number as ORG_UNIT_DEFINITION__GST_REGISTRATION_NUMBER,
        t0.branch_name as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        null,
        t0.claim_zone as ORG_UNIT_DEFINITION__ZONE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.branch_code1, '')) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_KYC_REFERENCE.KYC Reference Type=PROOF_OF_ADDRESS
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_ADDRESS' as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        t0.poa_status as PARTY_KYC_REFERENCE__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_KYC_REFERENCE.KYC Reference Type=PROOF_OF_IDENTITY
    select
        null, null, null, null, null, null,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_IDENTITY' as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        t0.poi_status as PARTY_KYC_REFERENCE__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=GROUP_CATEGORY
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GROUP_CATEGORY' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.group_category as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.pol_policy_number),''), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=ISNEEPRODUCT
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ISNEEPRODUCT' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.isneeproduct as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.pol_policy_number),''), '')) is not null

    union all

    -- branch 7: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=LOAN_LINKED
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOAN_LINKED' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.loan_linked as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.pol_policy_number),''), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TYPE_OF_PROPOSAL
    select
        null, null, null, null, null, null, null,
        nullif(t0.policy_number, '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TYPE_OF_PROPOSAL' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.type_of_proposal as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_policy_claim_history_msa_pv') }} t0
    where (nullif(t0.policy_number, '')) is not null

    union all

    -- branch 9: MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null, null, null, null, null, null,
        nullif(t0.policy_number, '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.status as POLICY_HEADER__POLICY_STATUS,
        t0.sub_status as POLICY_HEADER__POLICY_SUB_STATUS,
        null, null, null, null, null,
        t0.risk_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.risk_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_policy_claim_history_msa_pv') }} t0
    where (nullif(t0.policy_number, '')) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA
    select
        null, null, null, null, null,
        nullif(t0.policy_branch, '') as ORG_UNIT_BK,
        null,
        nullif(t0.policy_number, '') as POLICY_BK,
        nullif(t0.product_code, '') as PRODUCT_BK,
        nullif(t0.proposal_number, '') as PROPOSAL_BK,
        null, null, null, null, null, null, null,
        1 as __LNK_POLICY_ORG_UNIT,
        null,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.base_currency as POLICY_HEADER__CURRENCY_CODE,
        null, null, null, null, null, null,
        t0.policy_status as POLICY_HEADER__POLICY_STATUS,
        t0.policy_sub_status as POLICY_HEADER__POLICY_SUB_STATUS,
        t0.policy_term as POLICY_HEADER__POLICY_TERM,
        null, null,
        t0.premium_frequency as POLICY_HEADER__PREMIUM_FREQUENCY,
        null,
        t0.policy_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.policy_inception_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr') }} t0
    where (coalesce(nullif(t0.policy_branch, ''), nullif(t0.policy_number, ''), nullif(t0.product_code, ''), nullif(t0.proposal_number, ''))) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.member_code),''), '') as PARTY_BK,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        nullif(nullif(trim(j4.product_code),''), '') as PRODUCT_BK,
        nullif(nullif(trim(j4.proposal_number),''), '') as PROPOSAL_BK,
        nullif('MEMBER:' || nullif(trim(t0.member_code),''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        null, null, null, null, null, null, null,
        t0.other_bagic_policy_number as AUG_PARTY_POLICY_HISTORY__OTHER_HELD_POLICY_NUMBER,
        t0.discount_loading_type as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.applicable_for_other_member as AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICABLE_TO_OTHER_MEMBERS_INDICATOR,
        t0.applicable_level as AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICATION_LEVEL,
        null, null, null, null, null, null, null, null,
        t0.type_of_previous_insurance as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURANCE_TYPE,
        t0.insurer_code as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_CODE,
        null,
        t0.previous_policy_expiry_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        t0.previous_policy_start_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        null, null, null, null, null, null, null, null,
        t0.icd_code as AUG_RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        t0.medication_dosage as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DOSAGE,
        t0.medications_duration as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DURATION,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.number_of_claims_lodged as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_status as POLICY_HEADER__POLICY_STATUS,
        null, null, null, null, null, null,
        t0.policy_risk_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.net_premium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif('MEMBER:' || nullif(trim(t0.member_code),''), ''), nullif(nullif(trim(j4.policy_number),''), ''), nullif(nullif(trim(j4.product_code),''), ''), nullif(nullif(trim(j4.proposal_number),''), ''), nullif(nullif(trim(t0.member_code),''), ''))) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_DISCOUNT_LOADING_APPLIED.Item Code=LOADING
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOADING' as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.loading_waive_off as AUG_POLICY_DISCOUNT_LOADING_APPLIED__LOADING_WAIVER_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.member_code),''), '') as PARTY_BK,
        null, null, null, null,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        t0.appointee_name as LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME,
        t0.relationship_of_appointee_with_the_nominee as LNK_ROLE_NOMINEE_BENEFICIARY__GUARDIAN_RELATIONSHIP,
        null,
        t0.nominee_date_of_birth as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_DATE_OF_BIRTH,
        t0.nominee_ as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    where (nullif(nullif(trim(t0.member_code),''), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif('UWR-ASSESSMENT:' || nullif(trim(j2.proposal_number),''), '') as ASSESSMENT_BK,
        null,
        nullif(t0.loan_account_number, '') as FINANCIAL_ACCOUNT_BK,
        null,
        nullif('LOC:' || nullif(trim(t0.location_code),''), '') as LOCATION_BK,
        nullif(coalesce( nullif(trim(t0.branch_code),'') , nullif(trim(t0.policy_branch_code),'') ), '') as ORG_UNIT_BK,
        nullif(t0.proposer_code, '') as PARTY_BK,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null,
        1 as __LNK_POLICY_LOCATION,
        null, null, null, null, null,
        t0.sanctioned_loan_amount as ACCOUNT_BALANCE__OPENING_BALANCE,
        t0.other_type_of_loan as ACCOUNT_DEFINITION__ACCOUNT_CATEGORY,
        t0.type_of_loan as ACCOUNT_DEFINITION__ACCOUNT_TYPE,
        null,
        t0.misrepresentation as ASSESSMENT_FRAUD_INVESTIGATION__MISREPRESENTATION_INDICATOR,
        null, null, null, null, null, null, null,
        t0.other_remarks as AUG_POLICY_HEADER__OTHER_REMARKS,
        null,
        t0.name_of_the_premium_payer as AUG_POLICY_HEADER__PREMIUM_PAYER_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.branch_vertical_name as ORG_UNIT_DEFINITION__FUNCTIONAL_TYPE,
        null,
        t0.branch_name as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        t0.cluster_name as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
        null,
        t0.loss_ratio as PARTY_CLAIM_HISTORY__CLAIM_RATIO,
        null, null, null,
        t0.first_policy_inception_date as PARTY_POLICY_HISTORY__FIRST_POLICY_DATE,
        null, null,
        t0.employer_contribution_percentage as POLICY_GROUP__EMPLOYER_CONTRIBUTION_PERCENTAGE,
        t0.group_domain_size as POLICY_GROUP__GROUP_SIZE,
        null, null,
        t0.member_participation as POLICY_GROUP__MEMBER_ENROLMENT_BASIS,
        t0.coinsurance as POLICY_HEADER__CO_INSURANCE_INDICATOR,
        t0.premium_currency as POLICY_HEADER__CURRENCY_CODE,
        t0.issuance_source as POLICY_HEADER__ISSUING_CHANNEL_REFERENCE,
        t0.line_of_business as POLICY_HEADER__LINE_OF_BUSINESS,
        t0.no_of_members as POLICY_HEADER__NUMBER_OF_LIVES_COVERED,
        t0.business_source_hlth as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        t0.az_policy_number as POLICY_HEADER__POLICY_NUMBER,
        t0.remarks as POLICY_HEADER__POLICY_REMARKS,
        null, null,
        t0.policy_tenure as POLICY_HEADER__POLICY_TERM,
        null, null,
        t0.payment_frequency as POLICY_HEADER__PREMIUM_FREQUENCY,
        t0.premium_payer as POLICY_HEADER__PREMIUM_PAYER_REFERENCE,
        null,
        t0.policy_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        t0.policy_effective_time as POLICY_HEADER__RISK_START_TIME,
        t0.sum_insured as POLICY_HEADER__SUM_INSURED_TOTAL,
        null, null, null, null, null, null, null,
        t0.emi_applicable as POLICY_PREMIUM_SUMMARY__INSTALMENT_INDICATOR,
        t0.loyalty_discounts as POLICY_PREMIUM_SUMMARY__LOYALTY_DISCOUNT_AMOUNT,
        t0.net_premium_in_premium_currency as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        t0.premium_shortfall_on_issue as POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING,
        t0.collection_amount as POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED,
        t0.cgst_amount as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        null,
        t0.igst_amount as POLICY_TAX_BREAKUP__IGST_AMOUNT,
        t0.sgst_amount as POLICY_TAX_BREAKUP__SGST_AMOUNT,
        null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('LOC:' || nullif(trim(t0.location_code),''), ''), nullif('UWR-ASSESSMENT:' || nullif(trim(j2.proposal_number),''), ''), nullif(coalesce( nullif(trim(t0.branch_code),'') , nullif(trim(t0.policy_branch_code),'') ), ''), nullif(nullif(trim(j2.policy_number),''), ''), nullif(t0.loan_account_number, ''), nullif(t0.proposer_code, ''))) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(md5(normalise(nullif(trim(t0.inwarding_branch_name), ''))), '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inwarding_branch_name as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(t0.inwarding_branch_name), ''))), '')) is not null

    union all

    -- branch 16: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(t0.policy_branch_code, '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_branch_name as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.policy_branch_code, '')) is not null

    union all

    -- branch 17: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_KYC_REFERENCE.KYC Reference Type=PROOF_OF_ADDRESS
    select
        null, null, null, null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_ADDRESS' as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        t0.poa_status as PARTY_KYC_REFERENCE__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 18: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_KYC_REFERENCE.KYC Reference Type=PROOF_OF_IDENTITY
    select
        null, null, null, null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_IDENTITY' as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        t0.poi_status as PARTY_KYC_REFERENCE__VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_SOURCE
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BUSINESS_SOURCE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.business_source as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 20: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=CBM_DATA_SOURCE
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CBM_DATA_SOURCE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.cbm_data_source as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 21: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=CROSSSELL
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CROSSSELL' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.crosssell as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=GROUP_CATEGORY
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GROUP_CATEGORY' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.group_category as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 23: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=PAYER_TYPE
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAYER_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.payer_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=POLICY_REFERENCE_TYPE
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICY_REFERENCE_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.policy_reference_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=PORTABILITY_CATEGORY
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PORTABILITY_CATEGORY' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.portability_category as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 26: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=PORTABILITY_MIGRATION_CATEGORY
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PORTABILITY_MIGRATION_CATEGORY' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.portability_migartion_category as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 27: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=PRIORITY
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PRIORITY' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.priority_flag as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 28: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=SUB_PLAN_TYPE
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_PLAN_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.sub_plan_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 29: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TYPE_OF_BUSINESS
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TYPE_OF_BUSINESS' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.type_of_business as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 30: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null,
        nullif('LOC:' || nullif(trim(t0.location_code),''), '') as LOCATION_BK,
        nullif(t0.branch_code, '') as ORG_UNIT_BK,
        null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null,
        1 as __LNK_ORG_UNIT_LOCATION,
        null, null,
        1 as __LNK_POLICY_ORG_UNIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    left join {{ ref('stg_mxh__uwr_basic_detail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('LOC:' || nullif(trim(t0.location_code),''), ''), nullif(nullif(trim(j2.policy_number),''), ''), nullif(t0.branch_code, ''))) is not null

    union all

    -- branch 31: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        null, null,
        nullif(t0.loan_account_number, '') as FINANCIAL_ACCOUNT_BK,
        null, null, null,
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        nullif(nullif(trim(j5.product_code),''), '') as PRODUCT_BK,
        nullif(nullif(trim(j5.proposal_number),''), '') as PROPOSAL_BK,
        nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        t0.sanctioned_loan_amount as ACCOUNT_BALANCE__OPENING_BALANCE,
        t0.other_type_of_loan as ACCOUNT_DEFINITION__ACCOUNT_CATEGORY,
        t0.type_of_loan as ACCOUNT_DEFINITION__ACCOUNT_TYPE,
        null, null, null,
        t0.loan_tenure_in_years as AUG_ACCOUNT_DEFINITION__LOAN_TENURE_YEARS,
        t0.other_bagic_policy_number as AUG_PARTY_POLICY_HISTORY__OTHER_HELD_POLICY_NUMBER,
        t0.discount_loading_type as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.applicable_for_other_member as AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICABLE_TO_OTHER_MEMBERS_INDICATOR,
        t0.applicable_level as AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICATION_LEVEL,
        null, null, null, null, null, null, null, null,
        t0.type_of_previous_insurance as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURANCE_TYPE,
        t0.insurer_code as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_CODE,
        t0.international_sum_insured_in_previous_policy as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INTERNATIONAL_SUM_INSURED,
        t0.previous_policy_expiry_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
        t0.previous_policy_start_date as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
        null, null, null, null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as AUG_RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK,
        t0.eligible_sum_insured as AUG_RISK_HEALTH_MEMBER_COVERAGE__ELIGIBLE_SUM_INSURED,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
        t0.icd_code as AUG_RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
        t0.medication_dosage as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DOSAGE,
        t0.medications_duration as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DURATION,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.number_of_claims_lodged as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_status as POLICY_HEADER__POLICY_STATUS,
        null, null, null,
        t0.type_of_policy as POLICY_HEADER__POLICY_TYPE,
        null, null,
        t0.policy_risk_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.eligibility_parameter as PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.eligibility_parameter as PRODUCT_UW_RULE__TRIGGER_CONDITION,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j4.KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif('MEMBER:' || coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(nullif(trim(j5.policy_number),''), ''), nullif(nullif(trim(j5.product_code),''), ''), nullif(nullif(trim(j5.proposal_number),''), ''), nullif(t0.loan_account_number, ''))) is not null

    union all

    -- branch 32: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): AUG_POLICY_DISCOUNT_LOADING_APPLIED.Item Code=LOADING
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOADING' as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.loading_waive_off as AUG_POLICY_DISCOUNT_LOADING_APPLIED__LOADING_WAIVER_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number),''), '')) is not null

    union all

    -- branch 33: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW | child-key literal(s): LNK_ROLE_NOMINEE_BENEFICIARY.Role Type=NOMINEE_BENEFICIARY
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        null, null, null, null,
        'NOMINEE_BENEFICIARY' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NOMINEE_BENEFICIARY' as LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
        t0.appointee_name as LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME,
        t0.relationship_of_appointee_with_the_nominee as LNK_ROLE_NOMINEE_BENEFICIARY__GUARDIAN_RELATIONSHIP,
        t0.percentage as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINATION_PERCENTAGE,
        t0.nominee_date_of_birth as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_DATE_OF_BIRTH,
        t0.nominee_ as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j4.KEY_HASH
    where (nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '')) is not null

    union all

    -- branch 34: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_POLICY_AND_CLAIM_HISTORY | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TYPE_OF_PROPOSAL
    select
        null, null, null, null, null, null, null,
        nullif(t0.policy_number, '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TYPE_OF_PROPOSAL' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.type_of_proposal as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_memd_tabs_policy_and_claim_history') }} t0
    where (nullif(t0.policy_number, '')) is not null

    union all

    -- branch 35: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_POLICY_AND_CLAIM_HISTORY
    select
        null, null, null, null, null, null, null,
        nullif(t0.policy_number, '') as POLICY_BK,
        nullif(t0.product_code, '') as PRODUCT_BK,
        nullif(t0.view_proposal_number, '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_PROPOSAL_PRODUCT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.status as POLICY_HEADER__POLICY_STATUS,
        t0.sub_status as POLICY_HEADER__POLICY_SUB_STATUS,
        null, null, null, null, null,
        t0.risk_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.risk_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_memd_tabs_policy_and_claim_history') }} t0
    where (coalesce(nullif(t0.policy_number, ''), nullif(t0.product_code, ''), nullif(t0.view_proposal_number, ''))) is not null

    union all

    -- branch 36: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BILL_FORM
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BILL_FORM' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.bill_form as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    left join {{ ref('stg_mxh__uwr_payment_info') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 37: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TYPE_OF_BUSINESS
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TYPE_OF_BUSINESS' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.type_of_business as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    left join {{ ref('stg_mxh__uwr_payment_info') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 38: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null, null,
        nullif(md5(normalise(nullif(trim('PREMIUM-COLLECTION|' || coalesce(nullif(trim(j2.policy_number),''),'') || '|' || coalesce(t0.account_number,'')), 'PREMIUM-COLLECTION||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null,
        1 as __LNK_FINTXN_PARTY,
        1 as __LNK_FINTXN_POLICY,
        null, null, null, null,
        1 as __LNK_POLICY_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.employer_contribution_percentage as POLICY_GROUP__EMPLOYER_CONTRIBUTION_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payment_frequency as POLICY_HEADER__PREMIUM_FREQUENCY,
        null, null, null, null, null,
        t0.reference_number as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        t0.autodebit_flag as POLICY_INSTALMENT_SCHEDULE__AUTO_DEBIT_INDICATOR,
        t0.payment_cycle_raised_till_date as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
        t0.amount as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    left join {{ ref('stg_mxh__uwr_payment_info') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), ''), nullif(md5(normalise(nullif(trim('PREMIUM-COLLECTION|' || coalesce(nullif(trim(j2.policy_number),''),'') || '|' || coalesce(t0.account_number,'')), 'PREMIUM-COLLECTION||'))), ''), nullif(nullif(trim(j2.policy_number),''), ''))) is not null

    union all

    -- branch 39: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.reference_number1 as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        null, null,
        t0.amount1 as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    left join {{ ref('stg_mxh__uwr_payment_info') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 40: MAXI_HLTH_UWR_VW_DATA_POLICY_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_PIVOT_VW
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.paymentduedate as AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        t0.invoicenumber as AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_INVOICE_NUMBER,
        t0.paymenttodate as AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_PERIOD_END_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.paymentduedate as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
        null,
        t0.paymentduedate as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
        t0.paymentamount as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
        t0.paymentstatus as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_STATUS,
        t0.paymentunpaidamount as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
        t0.actualpaymentdate as POLICY_INSTALMENT_SCHEDULE__PAID_DATE,
        null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_policy_payment_cycle_dtls_payment_cycle_dtls_pa_3976c41e') }} t0
    left join {{ ref('stg_mxh__uwr_policy_payment_cycle_dtls_payment_cycle_dtls_pa_85699b21') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_policy_payment_cycle_dtls_payment_cycle_dtls') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_policy_payment_cycle_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 41: MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Adjusted Indicator=N, AUG_POLICY_PREMIUM_HEAD.Premium Head Code=PRORATED_PREMIUM, AUG_POLICY_PREMIUM_HEAD.Section=POLICY
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PRORATED_PREMIUM' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        t0.cover || '@' || t0.member_name as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'POLICY' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        'N' as AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        t0.prorated_premium as AUG_POLICY_PREMIUM_HEAD__PRO_RATA_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_premium_calculation_dtls') }} t0
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.policy_number),''), '')) is not null

    union all

    -- branch 42: MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS
    select
        null,
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        null, null, null, null, null,
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.duration as POLICY_HEADER__POLICY_TERM,
        t0.total_cover_period as POLICY_HEADER__POLICY_TERM_DAYS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.total_premium_for_policy_pre_tax as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_premium_calculation_dtls') }} t0
    left join {{ ref('stg_mxh__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover),''), ''), nullif(nullif(trim(j1.policy_number),''), ''))) is not null

)

select
    ASSESSMENT_BK,
    COVERAGE_BK,
    FINANCIAL_ACCOUNT_BK,
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    ROLE_TYPE_CODE,
    __LNK_FINTXN_PARTY,
    __LNK_FINTXN_POLICY,
    __LNK_ORG_UNIT_LOCATION,
    __LNK_POLICY_COVERAGE,
    __LNK_POLICY_LOCATION,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_PROPOSAL_POLICY,
    __LNK_PROPOSAL_PRODUCT,
    first_value(ACCOUNT_BALANCE__OPENING_BALANCE) ignore nulls over (partition by FINANCIAL_ACCOUNT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ACCOUNT_BALANCE__OPENING_BALANCE,
    first_value(ACCOUNT_DEFINITION__ACCOUNT_CATEGORY) ignore nulls over (partition by FINANCIAL_ACCOUNT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ACCOUNT_DEFINITION__ACCOUNT_CATEGORY,
    first_value(ACCOUNT_DEFINITION__ACCOUNT_TYPE) ignore nulls over (partition by FINANCIAL_ACCOUNT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ACCOUNT_DEFINITION__ACCOUNT_TYPE,
    first_value(ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY,
    first_value(ASSESSMENT_FRAUD_INVESTIGATION__MISREPRESENTATION_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_FRAUD_INVESTIGATION__MISREPRESENTATION_INDICATOR,
    first_value(ASSESSMENT_FRAUD_INVESTIGATION__TRIGGER_REASON) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_FRAUD_INVESTIGATION__TRIGGER_REASON,
    first_value(AUG_ACCOUNT_DEFINITION__LOAN_TENURE_YEARS) ignore nulls over (partition by FINANCIAL_ACCOUNT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ACCOUNT_DEFINITION__LOAN_TENURE_YEARS,
    first_value(AUG_PARTY_POLICY_HISTORY__OTHER_HELD_POLICY_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_POLICY_HISTORY__OTHER_HELD_POLICY_NUMBER,
    AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICABLE_TO_OTHER_MEMBERS_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICABLE_TO_OTHER_MEMBERS_INDICATOR,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICATION_LEVEL) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICATION_LEVEL,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__LOADING_WAIVER_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__LOADING_WAIVER_INDICATOR,
    first_value(AUG_POLICY_HEADER__OTHER_REMARKS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__OTHER_REMARKS,
    first_value(AUG_POLICY_HEADER__POLICYHOLDER_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__POLICYHOLDER_NAME,
    first_value(AUG_POLICY_HEADER__PREMIUM_PAYER_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PREMIUM_PAYER_NAME,
    AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    first_value(AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_INVOICE_NUMBER) ignore nulls over (partition by POLICY_BK, AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_INVOICE_NUMBER,
    first_value(AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_PERIOD_END_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_INSTALMENT_SCHEDULE__INSTALMENT_PERIOD_END_DATE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED_DEPENDENT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__CONTINUITY_PERIOD_GRANTED_DEPENDENT,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURANCE_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURANCE_TYPE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_CODE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INTERNATIONAL_SUM_INSURED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_INTERNATIONAL_SUM_INSURED,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_EXPIRY_DATE,
    first_value(AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_START_DATE,
    AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
    AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
    AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
    AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
    first_value(AUG_POLICY_PREMIUM_HEAD__PRO_RATA_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__PRO_RATA_AMOUNT,
    AUG_RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK,
    first_value(AUG_RISK_HEALTH_MEMBER_COVERAGE__ELIGIBLE_SUM_INSURED) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_HEALTH_MEMBER_COVERAGE__ELIGIBLE_SUM_INSURED,
    AUG_RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK,
    AUG_RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK,
    first_value(AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DOSAGE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK, AUG_RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DOSAGE,
    first_value(AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DURATION) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK, AUG_RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_HEALTH_MEMBER_MEDICAL__MEDICATION_DURATION,
    LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK,
    first_value(LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME) ignore nulls over (partition by PARTY_BK, LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_NOMINEE_BENEFICIARY__APPOINTEE_NAME,
    first_value(LNK_ROLE_NOMINEE_BENEFICIARY__GUARDIAN_RELATIONSHIP) ignore nulls over (partition by PARTY_BK, LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_NOMINEE_BENEFICIARY__GUARDIAN_RELATIONSHIP,
    first_value(LNK_ROLE_NOMINEE_BENEFICIARY__NOMINATION_PERCENTAGE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINATION_PERCENTAGE,
    first_value(LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_DATE_OF_BIRTH) ignore nulls over (partition by PARTY_BK, LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_DATE_OF_BIRTH,
    first_value(LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_NOMINEE_BENEFICIARY__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_NOMINEE_BENEFICIARY__NOMINEE_INDICATOR,
    first_value(ORG_UNIT_DEFINITION__FUNCTIONAL_TYPE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__FUNCTIONAL_TYPE,
    first_value(ORG_UNIT_DEFINITION__GST_REGISTRATION_NUMBER) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__GST_REGISTRATION_NUMBER,
    first_value(ORG_UNIT_DEFINITION__ORG_UNIT_NAME) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    first_value(ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__PARENT_ORG_UNIT_REFERENCE,
    first_value(ORG_UNIT_DEFINITION__ZONE_NAME) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ZONE_NAME,
    first_value(PARTY_CLAIM_HISTORY__CLAIM_RATIO) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CLAIM_HISTORY__CLAIM_RATIO,
    first_value(PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CLAIM_HISTORY__TOTAL_CLAIM_COUNT,
    PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
    first_value(PARTY_KYC_REFERENCE__VERIFICATION_STATUS) ignore nulls over (partition by PARTY_BK, PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC_REFERENCE__VERIFICATION_STATUS,
    first_value(PARTY_POLICY_HISTORY__FIRST_POLICY_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_POLICY_HISTORY__FIRST_POLICY_DATE,
    POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    first_value(POLICY_CLASSIFICATION__CLASSIFICATION_VALUE) ignore nulls over (partition by POLICY_BK, POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
    first_value(POLICY_GROUP__EMPLOYER_CONTRIBUTION_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_GROUP__EMPLOYER_CONTRIBUTION_PERCENTAGE,
    first_value(POLICY_GROUP__GROUP_SIZE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_GROUP__GROUP_SIZE,
    first_value(POLICY_GROUP__GROUP_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_GROUP__GROUP_TYPE,
    first_value(POLICY_GROUP__MASTER_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_GROUP__MASTER_POLICY_NUMBER,
    first_value(POLICY_GROUP__MEMBER_ENROLMENT_BASIS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_GROUP__MEMBER_ENROLMENT_BASIS,
    first_value(POLICY_HEADER__CO_INSURANCE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__CO_INSURANCE_INDICATOR,
    first_value(POLICY_HEADER__CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__CURRENCY_CODE,
    first_value(POLICY_HEADER__ISSUING_CHANNEL_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__ISSUING_CHANNEL_REFERENCE,
    first_value(POLICY_HEADER__LINE_OF_BUSINESS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__LINE_OF_BUSINESS,
    first_value(POLICY_HEADER__NUMBER_OF_LIVES_COVERED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__NUMBER_OF_LIVES_COVERED,
    first_value(POLICY_HEADER__POLICY_CHANNEL_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_CHANNEL_TYPE,
    first_value(POLICY_HEADER__POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_NUMBER,
    first_value(POLICY_HEADER__POLICY_REMARKS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_REMARKS,
    first_value(POLICY_HEADER__POLICY_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_STATUS,
    first_value(POLICY_HEADER__POLICY_SUB_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_SUB_STATUS,
    first_value(POLICY_HEADER__POLICY_TERM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_TERM,
    first_value(POLICY_HEADER__POLICY_TERM_DAYS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_TERM_DAYS,
    first_value(POLICY_HEADER__POLICY_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_TYPE,
    first_value(POLICY_HEADER__PREMIUM_FREQUENCY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__PREMIUM_FREQUENCY,
    first_value(POLICY_HEADER__PREMIUM_PAYER_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__PREMIUM_PAYER_REFERENCE,
    first_value(POLICY_HEADER__RISK_EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_EXPIRY_DATE,
    first_value(POLICY_HEADER__RISK_INCEPTION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_INCEPTION_DATE,
    first_value(POLICY_HEADER__RISK_START_TIME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_START_TIME,
    first_value(POLICY_HEADER__SUM_INSURED_TOTAL) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__SUM_INSURED_TOTAL,
    POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK,
    first_value(POLICY_INSTALMENT_SCHEDULE__AUTO_DEBIT_INDICATOR) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__AUTO_DEBIT_INDICATOR,
    first_value(POLICY_INSTALMENT_SCHEDULE__DUE_DATE) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__DUE_DATE,
    first_value(POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_AMOUNT,
    first_value(POLICY_INSTALMENT_SCHEDULE__INSTALMENT_STATUS) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__INSTALMENT_STATUS,
    first_value(POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__OUTSTANDING_AFTER_INSTALMENT,
    first_value(POLICY_INSTALMENT_SCHEDULE__PAID_DATE) ignore nulls over (partition by POLICY_BK, POLICY_INSTALMENT_SCHEDULE__INSTALMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INSTALMENT_SCHEDULE__PAID_DATE,
    first_value(POLICY_PREMIUM_SUMMARY__INSTALMENT_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__INSTALMENT_INDICATOR,
    first_value(POLICY_PREMIUM_SUMMARY__LOYALTY_DISCOUNT_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__LOYALTY_DISCOUNT_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__NET_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
    first_value(POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING,
    first_value(POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED,
    first_value(POLICY_TAX_BREAKUP__CGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__CGST_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__GSTIN_OF_INSURER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__GSTIN_OF_INSURER,
    first_value(POLICY_TAX_BREAKUP__IGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__IGST_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__SGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__SGST_AMOUNT,
    PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(PRODUCT_UW_RULE__TRIGGER_CONDITION) ignore nulls over (partition by PRODUCT_BK, PRODUCT_UW_RULE__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_UW_RULE__TRIGGER_CONDITION
from merged
