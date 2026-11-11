-- CENTRAL VIEW v11_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS
--   MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS_ADDITIONAL_DETAILS_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COMMON_CONTACT
--   SAT_AUG_PARTY_BENEFICIARY_LINE
--   SAT_AUG_PRODUCT_DEFINITION
--   SAT_CHANNEL_DEFINITION
--   SAT_FINTXN_PREMIUM
--   SAT_INSTRUMENT_DEFINITION
--   SAT_LNK_CLAIM_PARTY_ROLE
--   SAT_PARTY_DIGITAL_IDENTITY
--   SAT_PARTY_ONBOARDING_JOURNEY
--   SAT_PARTY_RELATIONSHIP_PROFILE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_PARTY
--   LNK_PARTY_ORG_UNIT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PAYMENT_INSTRUMENT
--   LNK_QUOTE_PARTY
--   LNK_QUOTE_PRODUCT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW | child-key literal(s): LNK_CLAIM_PARTY_ROLE.Role Sequence=1
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        nullif(t0.stake_code, '') as PARTY_BK,
        cast(null as varchar) as PAYMENT_INSTRUMENT_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        1 as __LNK_CLAIM_PARTY,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as number) as __LNK_POLICY_PAYMENT_INSTRUMENT,
        cast(null as number) as __LNK_QUOTE_PARTY,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        cast(null as varchar) as AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        cast(null as varchar) as AUG_COMMON_CONTACT__PREFERRED_CONTACT_DAY,
        cast(null as varchar) as AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_SEQUENCE_CK,
        cast(null as varchar) as AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_NAME,
        cast(null as varchar) as AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_PARTY_CODE,
        cast(null as varchar) as AUG_PRODUCT_DEFINITION__PRODUCT_DETAILS_TEXT,
        cast(null as varchar) as CHANNEL_DEFINITION__CHANNEL_NAME,
        cast(null as varchar) as CHANNEL_DEFINITION__CHANNEL_REMARKS,
        cast(null as varchar) as CHANNEL_DEFINITION__CHANNEL_TYPE,
        cast(null as varchar) as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        cast(null as varchar) as FINTXN_PREMIUM__COLLECTION_MODE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME,
        cast(null as varchar) as INSTRUMENT_DEFINITION__ACCOUNT_NUMBER_MASKED,
        cast(null as varchar) as INSTRUMENT_DEFINITION__BANK_NAME,
        cast(null as varchar) as INSTRUMENT_DEFINITION__BRANCH_NAME,
        cast(null as varchar) as INSTRUMENT_DEFINITION__CARD_NUMBER_MASKED,
        cast(null as varchar) as INSTRUMENT_DEFINITION__CARD_TYPE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__IFSC_CODE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__MANDATE_REFERENCE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__MANDATE_STATUS,
        cast(null as varchar) as INSTRUMENT_DEFINITION__VALID_FROM_DATE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__VALID_TO_DATE,
        t0.stake_holder as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        cast(null as varchar) as LNK_CLAIM_PARTY_ROLE__ATTRIBUTION_PERCENTAGE,
        t0.stake_holder as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE,
        cast(null as varchar) as LNK_CLAIM_PARTY_ROLE__ROLE_CATEGORY,
        cast(null as varchar) as LNK_CLAIM_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
        cast(null as varchar) as LNK_CLAIM_PARTY_ROLE__ROLE_END_DATE,
        cast(null as varchar) as PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as PARTY_DIGITAL_IDENTITY__CHANNEL_REGISTERED,
        cast(null as varchar) as PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER,
        cast(null as varchar) as PARTY_ONBOARDING_JOURNEY__EXAMINATION_REFERENCE,
        cast(null as varchar) as PARTY_ONBOARDING_JOURNEY__EXAMINATION_RESULT,
        cast(null as varchar) as PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE,
        cast(null as varchar) as PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME,
        cast(null as varchar) as PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS,
        cast(null as varchar) as PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_STATUS,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_adjust_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_adjust') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j2.claim_number),''), ''), nullif(t0.stake_code, ''))) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '|' || coalesce(t0.ifsc_code,'')), '|'))), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payble_at as INSTRUMENT_DEFINITION__BRANCH_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '|' || coalesce(t0.ifsc_code,'')), '|'))), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): LNK_CLAIM_PARTY_ROLE.Role Sequence=1
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.type_of_beneficiary as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        t0.percentage_for_payment as LNK_CLAIM_PARTY_ROLE__ATTRIBUTION_PERCENTAGE,
        t0.type_of_beneficiary as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE,
        null,
        t0.start_date as LNK_CLAIM_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
        t0.end_date as LNK_CLAIM_PARTY_ROLE__ROLE_END_DATE,
        null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_partydtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), ''), nullif(nullif(trim(j2.claim_number),''), ''))) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS | child-key literal(s): LNK_CLAIM_PARTY_ROLE.Role Sequence=1
    select
        nullif(nullif(trim(j1.claim_number),''), '') as CLAIM_BK,
        null, null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.role as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        null,
        t0.role as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations') }} t0
    left join {{ ref('stg_mxh__clm_cd') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = t0.KEY_HASH
    where (coalesce(nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), ''), nullif(nullif(trim(j1.claim_number),''), ''))) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY | child-key literal(s): LNK_CLAIM_PARTY_ROLE.Role Sequence=1
    select
        nullif(nullif(trim(j2.claim_number),''), '') as CLAIM_BK,
        null, null, null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.stakeholder as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        null,
        t0.stakeholder as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE,
        t0.stakeholder_role as LNK_CLAIM_PARTY_ROLE__ROLE_CATEGORY,
        t0.effective_date as LNK_CLAIM_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
        null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations') }} j1 on j1.KEY_HASH = t0.FOREIGN_KEY
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j2.claim_number),''), ''), nullif(nullif(trim(t0.party_code),''), ''))) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '|' || coalesce(t0.ifsc_code,'')), '|'))), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payble_at as INSTRUMENT_DEFINITION__BRANCH_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '|' || coalesce(t0.ifsc_code,'')), '|'))), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_CLAIM_PARTY_ROLE.Role Sequence=1
    select
        nullif(nullif(trim(j3.claim_number),''), '') as CLAIM_BK,
        null, null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.type_of_beneficiary as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        '1' as LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
        t0.percentage_for_payment as LNK_CLAIM_PARTY_ROLE__ATTRIBUTION_PERCENTAGE,
        t0.type_of_beneficiary as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE,
        null,
        t0.start_date as LNK_CLAIM_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
        t0.end_date as LNK_CLAIM_PARTY_ROLE__ROLE_END_DATE,
        null, null, null, null, null, null, null, null, null,
        4 as __PREC,
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

    -- branch 7: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null,
        nullif('CHANNEL:' || upper(nullif(trim(t0.channel_name),'')), '') as DISTRIBUTION_CHANNEL_BK,
        null, null, null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '#' || coalesce(t0.bank_ifsc_code,'')), '#'))), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.channel_name as CHANNEL_DEFINITION__CHANNEL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.emandate_registration as INSTRUMENT_DEFINITION__MANDATE_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (coalesce(nullif('CHANNEL:' || upper(nullif(trim(t0.channel_name),'')), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.account_number,'') || '#' || coalesce(t0.bank_ifsc_code,'')), '#'))), ''))) is not null

    union all

    -- branch 8: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null,
        nullif(t0.producer_code, '') as DISTRIBUTION_CHANNEL_BK,
        null, null, null, null,
        nullif('MANDATE:' || nullif(trim(t0.to_debit1),''), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.producer_type as CHANNEL_DEFINITION__CHANNEL_TYPE,
        t0.sub_imd_code as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        null,
        t0.premium_payer1 as INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME,
        t0.to_debit1 as INSTRUMENT_DEFINITION__ACCOUNT_NUMBER_MASKED,
        t0.with_bank1 as INSTRUMENT_DEFINITION__BANK_NAME,
        null, null, null, null,
        t0.reference_number1 as INSTRUMENT_DEFINITION__MANDATE_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (coalesce(nullif('MANDATE:' || nullif(trim(t0.to_debit1),''), ''), nullif(t0.producer_code, ''))) is not null

    union all

    -- branch 9: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('MANDATE:' || nullif(trim(t0.to_debit),''), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.to_debit as INSTRUMENT_DEFINITION__ACCOUNT_NUMBER_MASKED,
        t0.with_bank as INSTRUMENT_DEFINITION__BANK_NAME,
        null, null, null, null,
        t0.reference_number as INSTRUMENT_DEFINITION__MANDATE_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('MANDATE:' || nullif(trim(t0.to_debit),''), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_DIGITAL_IDENTITY.Active Sequence Number=POLICYHOLDER_PORTAL
    select
        null, null, null, null, null,
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICYHOLDER_PORTAL' as PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.policyholder_portal as PARTY_DIGITAL_IDENTITY__CHANNEL_REGISTERED,
        null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(nullif(trim(t0.policyholder_code),''), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null,
        nullif(md5(normalise(nullif(trim('PREMIUM-COLLECTION|' || coalesce(nullif(trim(j2.policy_number),''),'') || '|' || coalesce(t0.account_number,'')), 'PREMIUM-COLLECTION||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null,
        nullif(coalesce('UMRN:' || nullif(trim(t0.reference_number),'') ,'ACCT:' || nullif(trim(t0.account_number),'') ), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payment_mode as FINTXN_PREMIUM__COLLECTION_MODE,
        null,
        t0.to_debit as INSTRUMENT_DEFINITION__ACCOUNT_NUMBER_MASKED,
        null, null, null, null, null, null,
        t0.emandate_registration as INSTRUMENT_DEFINITION__MANDATE_STATUS,
        t0.period_from as INSTRUMENT_DEFINITION__VALID_FROM_DATE,
        t0.period_to as INSTRUMENT_DEFINITION__VALID_TO_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    left join {{ ref('stg_mxh__uwr_payment_info') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce('UMRN:' || nullif(trim(t0.reference_number),'') ,'ACCT:' || nullif(trim(t0.account_number),'') ), ''), nullif(md5(normalise(nullif(trim('PREMIUM-COLLECTION|' || coalesce(nullif(trim(j2.policy_number),''),'') || '|' || coalesce(t0.account_number,'')), 'PREMIUM-COLLECTION||'))), ''))) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(coalesce('UMRN:' || nullif(trim(t0.reference_number1),'') ,'ACCT:' || nullif(trim(t0.account_number1),'') ), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.to_debit1 as INSTRUMENT_DEFINITION__ACCOUNT_NUMBER_MASKED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('UMRN:' || nullif(trim(t0.reference_number1),'') ,'ACCT:' || nullif(trim(t0.account_number1),'') ), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_COMMON_CONTACT.Contact Point Type=LANDLINE, AUG_COMMON_CONTACT.Contact Priority Order=1
    select
        null, null, null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null,
        'LANDLINE' as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.best_day_to_call as AUG_COMMON_CONTACT__PREFERRED_CONTACT_DAY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_COMMON_CONTACT.Contact Point Type=LANDLINE_WORK, AUG_COMMON_CONTACT.Contact Priority Order=1
    select
        null, null, null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null,
        'LANDLINE_WORK' as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.best_day_to_callw as AUG_COMMON_CONTACT__PREFERRED_CONTACT_DAY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        null,
        nullif(t0.partner_ref, '') as DISTRIBUTION_CHANNEL_BK,
        null, null,
        nullif(nullif(trim(t0.branch),''), '') as ORG_UNIT_BK,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        nullif(t0.product_code, '') as PRODUCT_BK,
        nullif(t0.calculator_urn_number, '') as QUOTE_BK,
        null,
        1 as __LNK_PARTY_ORG_UNIT,
        null, null,
        1 as __LNK_QUOTE_PARTY,
        1 as __LNK_QUOTE_PRODUCT,
        null, null, null, null,
        t0.beneficiary_names as AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_NAME,
        t0.beneficiary_codes as AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_PARTY_CODE,
        t0.product_details as AUG_PRODUCT_DEFINITION__PRODUCT_DETAILS_TEXT,
        null,
        t0.partner_details as CHANNEL_DEFINITION__CHANNEL_REMARKS,
        t0.partner_type as CHANNEL_DEFINITION__CHANNEL_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.exam_details as PARTY_ONBOARDING_JOURNEY__EXAMINATION_REFERENCE,
        t0.examinations_details_for_irda_code as PARTY_ONBOARDING_JOURNEY__EXAMINATION_RESULT,
        t0.application_date as PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE,
        t0.previous_company_name as PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME,
        t0.no_of_years_of_work_experience as PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS,
        t0.are_you_an_existing_bajaj_allianz_customer as PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_STATUS,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j2.party_code),''), ''), nullif(nullif(trim(t0.branch),''), ''), nullif(t0.calculator_urn_number, ''), nullif(t0.partner_ref, ''), nullif(t0.product_code, ''))) is not null

    union all

    -- branch 16: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_DIGITAL_IDENTITY.Active Sequence Number=USER_CODE
    select
        null, null, null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USER_CODE' as PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        null,
        t0.user_code as PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER,
        null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 17: MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS
    select
        null,
        nullif(t0.imd_code, '') as DISTRIBUTION_CHANNEL_BK,
        nullif('UWR_COLLECTION:' || nullif(trim(t0.collection_payment_number),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null,
        nullif('CHQ:' || nullif(trim(coalesce(upper(trim(t0.drawee_bank_name)),'') || '#' || coalesce(trim(t0.chq_ins_number),'')), '#'), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.imd_code_name as CHANNEL_DEFINITION__CHANNEL_NAME,
        null,
        t0.imd_channel as CHANNEL_DEFINITION__CHANNEL_TYPE,
        t0.sub_code as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        t0.mode as FINTXN_PREMIUM__COLLECTION_MODE,
        null, null,
        t0.drawee_bank_name as INSTRUMENT_DEFINITION__BANK_NAME,
        t0.drawee_bank_branch as INSTRUMENT_DEFINITION__BRANCH_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_view_collections') }} t0
    where (coalesce(nullif('CHQ:' || nullif(trim(coalesce(upper(trim(t0.drawee_bank_name)),'') || '#' || coalesce(trim(t0.chq_ins_number),'')), '#'), ''), nullif('UWR_COLLECTION:' || nullif(trim(t0.collection_payment_number),''), ''), nullif(t0.imd_code, ''))) is not null

    union all

    -- branch 18: MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS
    select
        null,
        nullif(t0.sub_imd_code, '') as DISTRIBUTION_CHANNEL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_imd_channel as CHANNEL_DEFINITION__CHANNEL_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_view_collections') }} t0
    where (nullif(t0.sub_imd_code, '')) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS_ADDITIONAL_DETAILS_PIVOT_VW
    select
        null, null, null,
        nullif('LOC:' || md5(normalise(nullif(trim(coalesce(t0.city_name,'')), ''))), '') as LOCATION_BK,
        null, null,
        nullif('UWR_COLL_INSTR:' || md5(normalise(nullif(trim(coalesce(t0.card_numberlast_4_digits,'') || '#' || coalesce(t0.card_type,'') || '#' || coalesce(t0.issuing_bank,'') || '#' || coalesce(t0.ifsc_code,'') || '#' || coalesce(t0.payer_bank_account_no,'') || '#' || coalesce(t0.micr_code,'')), '#####'))), '') as PAYMENT_INSTRUMENT_BK,
        nullif(t0.child_policy, '') as POLICY_BK,
        null, null, null, null,
        1 as __LNK_POLICY_LOCATION,
        1 as __LNK_POLICY_PAYMENT_INSTRUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cheque_issued_by_name as INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME,
        t0.payer_bank_account_no as INSTRUMENT_DEFINITION__ACCOUNT_NUMBER_MASKED,
        t0.issuing_bank as INSTRUMENT_DEFINITION__BANK_NAME,
        null,
        t0.card_numberlast_4_digits as INSTRUMENT_DEFINITION__CARD_NUMBER_MASKED,
        t0.card_type as INSTRUMENT_DEFINITION__CARD_TYPE,
        t0.ifsc_code as INSTRUMENT_DEFINITION__IFSC_CODE,
        null, null, null,
        t0.card_expiry_date as INSTRUMENT_DEFINITION__VALID_TO_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_view_collections_additional_dtls_pv') }} t0
    where (coalesce(nullif('LOC:' || md5(normalise(nullif(trim(coalesce(t0.city_name,'')), ''))), ''), nullif('UWR_COLL_INSTR:' || md5(normalise(nullif(trim(coalesce(t0.card_numberlast_4_digits,'') || '#' || coalesce(t0.card_type,'') || '#' || coalesce(t0.issuing_bank,'') || '#' || coalesce(t0.ifsc_code,'') || '#' || coalesce(t0.payer_bank_account_no,'') || '#' || coalesce(t0.micr_code,'')), '#####'))), ''), nullif(t0.child_policy, ''))) is not null

)

select
    CLAIM_BK,
    DISTRIBUTION_CHANNEL_BK,
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    PAYMENT_INSTRUMENT_BK,
    POLICY_BK,
    PRODUCT_BK,
    QUOTE_BK,
    __LNK_CLAIM_PARTY,
    __LNK_PARTY_ORG_UNIT,
    __LNK_POLICY_LOCATION,
    __LNK_POLICY_PAYMENT_INSTRUMENT,
    __LNK_QUOTE_PARTY,
    __LNK_QUOTE_PRODUCT,
    AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
    AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
    first_value(AUG_COMMON_CONTACT__PREFERRED_CONTACT_DAY) ignore nulls over (partition by PARTY_BK, AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK, AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CONTACT__PREFERRED_CONTACT_DAY,
    AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_SEQUENCE_CK,
    first_value(AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_NAME) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_NAME,
    first_value(AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_PARTY_CODE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BENEFICIARY_LINE__BENEFICIARY_PARTY_CODE,
    first_value(AUG_PRODUCT_DEFINITION__PRODUCT_DETAILS_TEXT) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DEFINITION__PRODUCT_DETAILS_TEXT,
    first_value(CHANNEL_DEFINITION__CHANNEL_NAME) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__CHANNEL_NAME,
    first_value(CHANNEL_DEFINITION__CHANNEL_REMARKS) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__CHANNEL_REMARKS,
    first_value(CHANNEL_DEFINITION__CHANNEL_TYPE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__CHANNEL_TYPE,
    first_value(CHANNEL_DEFINITION__SUB_CHANNEL_CODE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
    first_value(FINTXN_PREMIUM__COLLECTION_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__COLLECTION_MODE,
    first_value(INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME,
    first_value(INSTRUMENT_DEFINITION__ACCOUNT_NUMBER_MASKED) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__ACCOUNT_NUMBER_MASKED,
    first_value(INSTRUMENT_DEFINITION__BANK_NAME) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__BANK_NAME,
    first_value(INSTRUMENT_DEFINITION__BRANCH_NAME) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__BRANCH_NAME,
    first_value(INSTRUMENT_DEFINITION__CARD_NUMBER_MASKED) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__CARD_NUMBER_MASKED,
    first_value(INSTRUMENT_DEFINITION__CARD_TYPE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__CARD_TYPE,
    first_value(INSTRUMENT_DEFINITION__IFSC_CODE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__IFSC_CODE,
    first_value(INSTRUMENT_DEFINITION__MANDATE_REFERENCE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__MANDATE_REFERENCE,
    first_value(INSTRUMENT_DEFINITION__MANDATE_STATUS) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__MANDATE_STATUS,
    first_value(INSTRUMENT_DEFINITION__VALID_FROM_DATE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__VALID_FROM_DATE,
    first_value(INSTRUMENT_DEFINITION__VALID_TO_DATE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__VALID_TO_DATE,
    LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
    LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK,
    first_value(LNK_CLAIM_PARTY_ROLE__ATTRIBUTION_PERCENTAGE) ignore nulls over (partition by CLAIM_BK, PARTY_BK, LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_CLAIM_PARTY_ROLE__ATTRIBUTION_PERCENTAGE,
    first_value(LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE) ignore nulls over (partition by CLAIM_BK, PARTY_BK, LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE,
    first_value(LNK_CLAIM_PARTY_ROLE__ROLE_CATEGORY) ignore nulls over (partition by CLAIM_BK, PARTY_BK, LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_CLAIM_PARTY_ROLE__ROLE_CATEGORY,
    first_value(LNK_CLAIM_PARTY_ROLE__ROLE_EFFECTIVE_DATE) ignore nulls over (partition by CLAIM_BK, PARTY_BK, LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_CLAIM_PARTY_ROLE__ROLE_EFFECTIVE_DATE,
    first_value(LNK_CLAIM_PARTY_ROLE__ROLE_END_DATE) ignore nulls over (partition by CLAIM_BK, PARTY_BK, LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_CLAIM_PARTY_ROLE__ROLE_END_DATE,
    PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(PARTY_DIGITAL_IDENTITY__CHANNEL_REGISTERED) ignore nulls over (partition by PARTY_BK, PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_DIGITAL_IDENTITY__CHANNEL_REGISTERED,
    first_value(PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER) ignore nulls over (partition by PARTY_BK, PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER,
    first_value(PARTY_ONBOARDING_JOURNEY__EXAMINATION_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ONBOARDING_JOURNEY__EXAMINATION_REFERENCE,
    first_value(PARTY_ONBOARDING_JOURNEY__EXAMINATION_RESULT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ONBOARDING_JOURNEY__EXAMINATION_RESULT,
    first_value(PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE,
    first_value(PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME,
    first_value(PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS,
    first_value(PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_STATUS
from merged
