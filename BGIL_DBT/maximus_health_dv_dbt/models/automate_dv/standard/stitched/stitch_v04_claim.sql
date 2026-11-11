-- CENTRAL VIEW v04_claim -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_MULTISET_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST
--   MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST_MULTISET_ATTRIBUTE
--   MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST_MULTISET_ATTRIBUTE_ATTRIBUTES
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_SETTLEMENT
--   SAT_AUG_FINTXN_TAX
--   SAT_AUG_LNK_CLAIM_PARTY_ROLE
--   SAT_CLAIM_DEDUCTION_WAIVER
--   SAT_CLAIM_FNOL
--   SAT_CLAIM_FRAUD
--   SAT_CLAIM_HEADER
--   SAT_CLAIM_INVESTIGATION_FINDING
--   SAT_CLAIM_QUALITY_AUDIT
--   SAT_CLAIM_RECOVERY_SALVAGE
--   SAT_CLAIM_SETTLEMENT
--   SAT_LOCATION_PROFILE
--   SAT_POLICY_PREMIUM_SETTLEMENT
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_PAYMENT_INSTRUMENT
--   LNK_CLAIM_POLICY
--   LNK_FINTXN_CLAIM
--   LNK_FINTXN_INSTRUMENT
--   LNK_FINTXN_PARTY
--   LNK_PARTY_PAYMENT_INSTRUMENT
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PRODUCT
--   LNK_PRODUCT_COVERAGE
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as PAYMENT_INSTRUMENT_BK,
        nullif(t0.pol_policy_number, '') as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as number) as __LNK_CLAIM_PARTY,
        cast(null as number) as __LNK_CLAIM_PAYMENT_INSTRUMENT,
        1 as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_FINTXN_CLAIM,
        cast(null as number) as __LNK_FINTXN_INSTRUMENT,
        cast(null as number) as __LNK_FINTXN_PARTY,
        cast(null as number) as __LNK_PARTY_PAYMENT_INSTRUMENT,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_PRODUCT_COVERAGE,
        cast(null as number) as __LNK_PROPOSAL_POLICY,
        cast(null as number) as __LNK_PROPOSAL_PRODUCT,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__PAYOUT_REASON,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_PAYABLE_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_DAYS,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_REASON,
        cast(null as varchar) as AUG_FINTXN_TAX__TAX_TYPE_CK,
        cast(null as varchar) as AUG_FINTXN_TAX__DIFFERENTIAL_TDS_INDICATOR,
        cast(null as varchar) as AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        cast(null as varchar) as AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        cast(null as varchar) as AUG_LNK_CLAIM_PARTY_ROLE__FIXED_PAYMENT_AMOUNT,
        cast(null as varchar) as CLAIM_DEDUCTION_WAIVER__WAIVER_TYPE,
        cast(null as varchar) as CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION,
        cast(null as varchar) as CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE,
        cast(null as varchar) as CLAIM_FRAUD__FRAUD_SCORE,
        cast(null as varchar) as CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR,
        cast(null as varchar) as CLAIM_FRAUD__FRAUD_TRIGGER_REASON,
        cast(null as varchar) as CLAIM_HEADER__CASHLESS_INDICATOR,
        cast(null as varchar) as CLAIM_HEADER__CLAIM_CATEGORY,
        cast(null as varchar) as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
        cast(null as varchar) as CLAIM_HEADER__CLAIM_REMARKS,
        t0.status as CLAIM_HEADER__CLAIM_STATUS,
        cast(null as varchar) as CLAIM_HEADER__CLAIM_TYPE,
        cast(null as varchar) as CLAIM_HEADER__GROSS_INCURRED_AMOUNT,
        cast(null as varchar) as CLAIM_HEADER__INTIMATION_CHANNEL,
        cast(null as varchar) as CLAIM_HEADER__LINE_OF_BUSINESS,
        cast(null as varchar) as CLAIM_HEADER__NOTIFICATION_DATE,
        cast(null as varchar) as CLAIM_HEADER__REGISTRATION_DATE,
        t0.reopen_indicator as CLAIM_HEADER__REOPENED_INDICATOR,
        cast(null as varchar) as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_INVESTIGATION_FINDING__FINDING_DESCRIPTION,
        cast(null as varchar) as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        cast(null as varchar) as CLAIM_INVESTIGATION_FINDING__INVESTIGATION_REFERENCE,
        cast(null as varchar) as CLAIM_INVESTIGATION_FINDING__TRIGGER_CODE,
        cast(null as varchar) as CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME,
        cast(null as varchar) as CLAIM_RECOVERY_SALVAGE__NET_RECOVERY_AMOUNT,
        cast(null as varchar) as CLAIM_RECOVERY_SALVAGE__RECOVERY_STATUS,
        cast(null as varchar) as CLAIM_SETTLEMENT__APPROVED_AMOUNT,
        cast(null as varchar) as CLAIM_SETTLEMENT__NEGOTIATION_AMOUNT,
        cast(null as varchar) as CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT,
        cast(null as varchar) as CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT,
        cast(null as varchar) as LOCATION_PROFILE__LOCATION_NAME,
        cast(null as varchar) as POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK,
        cast(null as varchar) as POLICY_PREMIUM_SETTLEMENT__SECTION_64VB_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd') }} t0
    where (coalesce(nullif(t0.claim_number, ''), nullif(t0.pol_policy_number, ''))) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j6.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.classification as CLAIM_HEADER__CLAIM_CATEGORY,
        null, null, null, null, null, null, null, null, null, null,
        t0.trigger_type as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null, null, null,
        t0.trigger_type as CLAIM_INVESTIGATION_FINDING__TRIGGER_CODE,
        null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_msa_msa_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr_msa_msa') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr_msa_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr_msa') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr_multiset_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claim_number),''), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim(j4.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null,
        nullif(nullif(trim(j8.pol_policy_number),''), '') as POLICY_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_POLICY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.claim_status as CLAIM_HEADER__CLAIM_STATUS,
        null, null, null, null, null, null, null,
        t0.investation_id as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        t0.investigation_remarks as CLAIM_INVESTIGATION_FINDING__FINDING_DESCRIPTION,
        null,
        t0.investation_id as CLAIM_INVESTIGATION_FINDING__INVESTIGATION_REFERENCE,
        null, null, null, null, null, null,
        t0.penal_interest_amount as CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT,
        t0.to_be_paid as CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT,
        null, null, null,
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
        nullif('COV:' || nullif(trim(t0.cover),''), '') as COVERAGE_BK,
        null,
        nullif('LOC:' || nullif(trim(t0.location_code),''), '') as LOCATION_BK,
        nullif(t0.branch_code1, '') as ORG_UNIT_BK,
        null, null,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        nullif(t0.product_code, '') as PRODUCT_BK,
        nullif(t0.proposal_number, '') as PROPOSAL_BK,
        null, null, null, null, null, null, null,
        1 as __LNK_POLICY_COVERAGE,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_PRODUCT_COVERAGE,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        t0.payout_reason as AUG_CLAIM_SETTLEMENT__PAYOUT_REASON,
        null, null, null, null, null, null, null, null, null,
        t0.waiverclaimcondition as CLAIM_DEDUCTION_WAIVER__WAIVER_TYPE,
        t0.claim_reason as CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION,
        t0.expected_amount as CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE,
        t0.fraudometer_score as CLAIM_FRAUD__FRAUD_SCORE,
        t0.suspected_fraud as CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR,
        t0.document_fraud_trigger as CLAIM_FRAUD__FRAUD_TRIGGER_REASON,
        t0.claim_mode as CLAIM_HEADER__CASHLESS_INDICATOR,
        t0.category_type as CLAIM_HEADER__CLAIM_CATEGORY,
        t0.new_claim_number as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
        t0.remarks as CLAIM_HEADER__CLAIM_REMARKS,
        null,
        t0.type_of_claim as CLAIM_HEADER__CLAIM_TYPE,
        null,
        t0.claim_submission_type as CLAIM_HEADER__INTIMATION_CHANNEL,
        t0.line_of_business as CLAIM_HEADER__LINE_OF_BUSINESS,
        t0.intimation_date as CLAIM_HEADER__NOTIFICATION_DATE,
        t0.claim_received_date as CLAIM_HEADER__REGISTRATION_DATE,
        null, null, null, null, null, null,
        t0.settlement_qc as CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME,
        t0.total_recovery_amount as CLAIM_RECOVERY_SALVAGE__NET_RECOVERY_AMOUNT,
        t0.recovery_action as CLAIM_RECOVERY_SALVAGE__RECOVERY_STATUS,
        t0.total_approved_amount as CLAIM_SETTLEMENT__APPROVED_AMOUNT,
        t0.negotiated_amount as CLAIM_SETTLEMENT__NEGOTIATION_AMOUNT,
        t0.penal_interest_data as CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT,
        t0.total_final_payable_amount as CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT,
        t0.location_name as LOCATION_PROFILE__LOCATION_NAME,
        null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('COV:' || nullif(trim(t0.cover),''), ''), nullif('LOC:' || nullif(trim(t0.location_code),''), ''), nullif(nullif(trim(j2.pol_policy_number),''), ''), nullif(t0.branch_code1, ''), nullif(t0.claim_number, ''), nullif(t0.product_code, ''), nullif(t0.proposal_number, ''))) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_PROLONGED_STAY_OR_UNJUSTIFIED_INVESTIGATIONS
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_PROLONGED_STAY_OR_UNJUSTIFIED_INVESTIGATIONS' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.the_case_has_prolongedstay_or_unjustified_investigations_procedure_our_of_tariff_reports_prepost_hospitalization_investigation_not_available as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_DOCUMENT_TAMPERING
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_DOCUMENT_TAMPERING' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.are_there_any_overwritings_or_strikingoff_text_on_the_papers_or_tampering_of_documents as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 6: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_HIGH_END_EQUIPMENT_OR_IMPLANTS
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_HIGH_END_EQUIPMENT_OR_IMPLANTS' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.does_the_instance_uses_highend_equipment_advanced_technology_or_costly_implants as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 7: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_COMORBIDITIES_OR_PED
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_COMORBIDITIES_OR_PED' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.does_the_patient_has_comorbidities_or_preexisting_ailments as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 8: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_CHRONIC_PRESENTED_AS_ACUTE_OR_CLOSE_PROXIMITY
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_CHRONIC_PRESENTED_AS_ACUTE_OR_CLOSE_PROXIMITY' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.is_it_a_case_of_chronic_conditions_projected_as_acute_illness_or_close_proximity_case as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claim_number),''), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_OPD_CONVERTED_TO_IPD
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_OPD_CONVERTED_TO_IPD' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.is_it_a_case_of_opd_converted_to_ipd as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claim_number),''), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_SURGERY_SPLITTING
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_SURGERY_SPLITTING' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.is_it_a_case_of_single_surgery_being_split_in_multiple_or_multiple_surgeries_in_same_ot as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claim_number),''), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_ADVERSE_FAMILY_HISTORY_IN_CASE_PAPERS
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_ADVERSE_FAMILY_HISTORY_IN_CASE_PAPERS' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.is_there_adverse_family_history_noted_in_case_papers as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claim_number),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): CLAIM_INVESTIGATION_FINDING.Finding Sequence=FRAUD_Q_ROOM_UPGRADE_OR_EXCESS_CHARGE
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'FRAUD_Q_ROOM_UPGRADE_OR_EXCESS_CHARGE' as CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
        null,
        t0.is_the_patient_being_admitted_in_a_room_higher_than_eligibility_higher_than_normal_treatment_cost_or_service_charge_test_charges_higher_than_authorized as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claim_number),''), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): POLICY_PREMIUM_SETTLEMENT.Settlement Line Sequence=SECTION_64VB
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j2.pol_policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'SECTION_64VB' as POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK,
        t0.c_64vb_status as POLICY_PREMIUM_SETTLEMENT__SECTION_64VB_STATUS,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claimdetail_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.pol_policy_number),''), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): AUG_FINTXN_TAX.Tax Type=TDS
    select
        null, null,
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j2.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'TDS' as AUG_FINTXN_TAX__TAX_TYPE_CK,
        t0.differential_tds as AUG_FINTXN_TAX__DIFFERENTIAL_TDS_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_partydtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j2.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): AUG_LNK_CLAIM_PARTY_ROLE.Role Sequence=1
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_beneficiary as AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        t0.fixed_payment as AUG_LNK_CLAIM_PARTY_ROLE__FIXED_PAYMENT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_partydtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), ''), nullif(nullif(trim(j2.claim_number),''), ''))) is not null

    union all

    -- branch 16: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null,
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j4.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '|' || coalesce(t0.ifsc_code,'')), '|'))), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null,
        1 as __LNK_CLAIM_PARTY,
        1 as __LNK_CLAIM_PAYMENT_INSTRUMENT,
        null,
        1 as __LNK_FINTXN_CLAIM,
        1 as __LNK_FINTXN_INSTRUMENT,
        1 as __LNK_FINTXN_PARTY,
        1 as __LNK_PARTY_PAYMENT_INSTRUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.lob as CLAIM_HEADER__LINE_OF_BUSINESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_partydtls') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_claim_partydtls') }} j3 on j3.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j4.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '|' || coalesce(t0.ifsc_code,'')), '|'))), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), ''), nullif(nullif(trim(j2.claim_number),''), ''))) is not null

    union all

    -- branch 17: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): AUG_FINTXN_TAX.Tax Type=TDS
    select
        null, null,
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j3.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'TDS' as AUG_FINTXN_TAX__TAX_TYPE_CK,
        t0.differential_tds as AUG_FINTXN_TAX__DIFFERENTIAL_TDS_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j3.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '')) is not null

    union all

    -- branch 18: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): AUG_LNK_CLAIM_PARTY_ROLE.Role Sequence=1
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        null, null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_beneficiary as AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        t0.fixed_payment as AUG_LNK_CLAIM_PARTY_ROLE__FIXED_PAYMENT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.claim_number),''), ''))) is not null

    union all

    -- branch 19: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        null,
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j6.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '|' || coalesce(t0.ifsc_code,'')), '|'))), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null,
        1 as __LNK_CLAIM_PARTY,
        1 as __LNK_CLAIM_PAYMENT_INSTRUMENT,
        null,
        1 as __LNK_FINTXN_CLAIM,
        1 as __LNK_FINTXN_INSTRUMENT,
        1 as __LNK_FINTXN_PARTY,
        1 as __LNK_PARTY_PAYMENT_INSTRUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.lob as CLAIM_HEADER__LINE_OF_BUSINESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j4 on j4.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j5.KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j6.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '|' || coalesce(t0.ifsc_code,'')), '|'))), ''), nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j3.claim_number),''), ''))) is not null

    union all

    -- branch 20: MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(t0.claim_number, '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.viewinward_number as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
        null,
        t0.status as CLAIM_HEADER__CLAIM_STATUS,
        t0.type_of_claim as CLAIM_HEADER__CLAIM_TYPE,
        t0.claimed_amount as CLAIM_HEADER__GROSS_INCURRED_AMOUNT,
        null, null,
        t0.date as CLAIM_HEADER__NOTIFICATION_DATE,
        null, null, null, null, null, null, null, null, null, null,
        t0.approved_amount as CLAIM_SETTLEMENT__APPROVED_AMOUNT,
        null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_claim_policy_history_msa_pv') }} t0
    where (nullif(t0.claim_number, '')) is not null

    union all

    -- branch 21: MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.penal_interest as AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_APPLICABLE_INDICATOR,
        t0.to_be_paid as AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_PAYABLE_INDICATOR,
        t0.no_of_days_delayed_settlement as AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_DAYS,
        t0.reason as AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.penal_interest_amount as CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT,
        null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_penal_interest_msa_pv') }} t0
    left join {{ ref('stg_mxh__clm_penal_interest_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_penal_interest_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_penal_interest') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.claim_number) as _V, count(distinct d0.claim_number) as _N
            from {{ ref('stg_mxh__clm_cd') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j4.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST_PIVOT_VW
    select
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.penal_interest_data as CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT,
        null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_penal_interest_pv') }} t0
    left join {{ ref('stg_mxh__clm_penal_interest') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.claim_number) as _V, count(distinct d0.claim_number) as _N
            from {{ ref('stg_mxh__clm_cd') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

)

select
    CLAIM_BK,
    COVERAGE_BK,
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    PAYMENT_INSTRUMENT_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    __LNK_CLAIM_PARTY,
    __LNK_CLAIM_PAYMENT_INSTRUMENT,
    __LNK_CLAIM_POLICY,
    __LNK_FINTXN_CLAIM,
    __LNK_FINTXN_INSTRUMENT,
    __LNK_FINTXN_PARTY,
    __LNK_PARTY_PAYMENT_INSTRUMENT,
    __LNK_POLICY_COVERAGE,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_PRODUCT,
    __LNK_PRODUCT_COVERAGE,
    __LNK_PROPOSAL_POLICY,
    __LNK_PROPOSAL_PRODUCT,
    first_value(AUG_CLAIM_SETTLEMENT__PAYOUT_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__PAYOUT_REASON,
    first_value(AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_APPLICABLE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_APPLICABLE_INDICATOR,
    first_value(AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_PAYABLE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__PENAL_INTEREST_PAYABLE_INDICATOR,
    first_value(AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_DAYS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_DAYS,
    first_value(AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__SETTLEMENT_DELAY_REASON,
    AUG_FINTXN_TAX__TAX_TYPE_CK,
    first_value(AUG_FINTXN_TAX__DIFFERENTIAL_TDS_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__DIFFERENTIAL_TDS_INDICATOR,
    AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
    AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
    first_value(AUG_LNK_CLAIM_PARTY_ROLE__FIXED_PAYMENT_AMOUNT) ignore nulls over (partition by CLAIM_BK, PARTY_BK, AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK, AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LNK_CLAIM_PARTY_ROLE__FIXED_PAYMENT_AMOUNT,
    first_value(CLAIM_DEDUCTION_WAIVER__WAIVER_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_DEDUCTION_WAIVER__WAIVER_TYPE,
    first_value(CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__PRELIMINARY_LOSS_DESCRIPTION,
    first_value(CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FNOL__PRELIMINARY_LOSS_ESTIMATE,
    first_value(CLAIM_FRAUD__FRAUD_SCORE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FRAUD__FRAUD_SCORE,
    first_value(CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FRAUD__FRAUD_SUSPICION_INDICATOR,
    first_value(CLAIM_FRAUD__FRAUD_TRIGGER_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_FRAUD__FRAUD_TRIGGER_REASON,
    first_value(CLAIM_HEADER__CASHLESS_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CASHLESS_INDICATOR,
    first_value(CLAIM_HEADER__CLAIM_CATEGORY) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_CATEGORY,
    first_value(CLAIM_HEADER__CLAIM_REFERENCE_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_REFERENCE_NUMBER,
    first_value(CLAIM_HEADER__CLAIM_REMARKS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_REMARKS,
    first_value(CLAIM_HEADER__CLAIM_STATUS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_STATUS,
    first_value(CLAIM_HEADER__CLAIM_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__CLAIM_TYPE,
    first_value(CLAIM_HEADER__GROSS_INCURRED_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__GROSS_INCURRED_AMOUNT,
    first_value(CLAIM_HEADER__INTIMATION_CHANNEL) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__INTIMATION_CHANNEL,
    first_value(CLAIM_HEADER__LINE_OF_BUSINESS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__LINE_OF_BUSINESS,
    first_value(CLAIM_HEADER__NOTIFICATION_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__NOTIFICATION_DATE,
    first_value(CLAIM_HEADER__REGISTRATION_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__REGISTRATION_DATE,
    first_value(CLAIM_HEADER__REOPENED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_HEADER__REOPENED_INDICATOR,
    CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK,
    first_value(CLAIM_INVESTIGATION_FINDING__FINDING_DESCRIPTION) ignore nulls over (partition by CLAIM_BK, CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_INVESTIGATION_FINDING__FINDING_DESCRIPTION,
    first_value(CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME) ignore nulls over (partition by CLAIM_BK, CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_INVESTIGATION_FINDING__FINDING_OUTCOME,
    first_value(CLAIM_INVESTIGATION_FINDING__INVESTIGATION_REFERENCE) ignore nulls over (partition by CLAIM_BK, CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_INVESTIGATION_FINDING__INVESTIGATION_REFERENCE,
    first_value(CLAIM_INVESTIGATION_FINDING__TRIGGER_CODE) ignore nulls over (partition by CLAIM_BK, CLAIM_INVESTIGATION_FINDING__FINDING_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_INVESTIGATION_FINDING__TRIGGER_CODE,
    first_value(CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_QUALITY_AUDIT__AUDIT_OUTCOME,
    first_value(CLAIM_RECOVERY_SALVAGE__NET_RECOVERY_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RECOVERY_SALVAGE__NET_RECOVERY_AMOUNT,
    first_value(CLAIM_RECOVERY_SALVAGE__RECOVERY_STATUS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RECOVERY_SALVAGE__RECOVERY_STATUS,
    first_value(CLAIM_SETTLEMENT__APPROVED_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__APPROVED_AMOUNT,
    first_value(CLAIM_SETTLEMENT__NEGOTIATION_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__NEGOTIATION_AMOUNT,
    first_value(CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__PENAL_INTEREST_AMOUNT,
    first_value(CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT,
    first_value(LOCATION_PROFILE__LOCATION_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LOCATION_PROFILE__LOCATION_NAME,
    POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK,
    first_value(POLICY_PREMIUM_SETTLEMENT__SECTION_64VB_STATUS) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SETTLEMENT__SECTION_64VB_STATUS
from merged
