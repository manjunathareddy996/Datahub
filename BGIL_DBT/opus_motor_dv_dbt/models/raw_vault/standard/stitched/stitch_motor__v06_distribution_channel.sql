-- CENTRAL VIEW v06_distribution_channel -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_CVTP_WS_DATA
--   BJAZ_MOT_OD_TP_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_TAC_DTLS
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_RTA_STATE_MASTER
--   BJAZ_WAP_MOT_GS_ACT_DTLS
--   RTA_CLUSTER_PREFERRED_DECLINE
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_CHANNEL_FIELD_ACTIVITY
--   SAT_MOTOR_AUG_FIN_RECEIPT
--   SAT_MOTOR_AUG_PRODUCT_DISTRIBUTION_RULES
--   SAT_MOTOR_AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION
--   SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST
--   SAT_CHANNEL_DEFINITION
--   SAT_CHANNEL_FIELD_ACTIVITY
--   SAT_COMMON_GEO
--   SAT_FINTXN_RECON_INSTRUMENT
--   SAT_INSTRUMENT_DEFINITION
--   SAT_PARTY_KYC_REFERENCE
--   SAT_PARTY_MARKETING
--   SAT_POLICY_CANCELLATION
--   SAT_POLICY_CLASSIFICATION
--   SAT_POLICY_CLAUSE_ATTACHED
--   SAT_PROPOSAL_HEADER
--   SAT_PROPOSAL_PAYMENT
--   SAT_PROPOSAL_SCRUTINY
--   SAT_RISK_MOTOR_LIABILITY_ADDON
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CHANNEL_ORG_UNIT
--   LNK_FINTXN_INSTRUMENT
--   LNK_FINTXN_POLICY
--   LNK_ORG_UNIT_LOCATION
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PAYMENT_INSTRUMENT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_CVTP_WS_DATA
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(to_char(t0.paymentid)), ''), '') as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as LOCATION_BK,
        nullif(nullif(trim(to_char(t0.bjaz_loc_code)), ''), '') as ORG_UNIT_BK,
        nullif(nullif(trim(t0.proposerpan), ''), '') as PARTY_BK,
        nullif(nullif(trim(t0.reconciledchequeno), ''), '') as PAYMENT_INSTRUMENT_BK,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        nullif(nullif(trim(t0.insproposalno), ''), '') as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        1 as __LNK_FINTXN_INSTRUMENT,
        1 as __LNK_FINTXN_POLICY,
        cast(null as number) as __LNK_ORG_UNIT_LOCATION,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PAYMENT_INSTRUMENT,
        1 as __LNK_POLICY_RISK_OBJECT,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__BANK_RELATIONSHIP_MANAGER_DETAILS,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__EXPECTED_PREMIUM_DISCUSSED,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__HEALTH_LINE_PREMIUM_DISCUSSED,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__NEXT_MEETING_DATE,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__NON_HEALTH_LINE_PREMIUM_DISCUSSED,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__PARTICIPANT_DESIGNATION,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__PRODUCTS_DISCUSSED,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_CONTACT_NUMBER,
        cast(null as varchar) as AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_NAME,
        cast(null as varchar) as AUG_FIN_RECEIPT__BANK_CHARGES_AMOUNT,
        cast(null as varchar) as AUG_FIN_RECEIPT__GATEWAY_RESPONSE_IDENTIFIER,
        cast(null as varchar) as AUG_FIN_RECEIPT__GATEWAY_TRACE_NUMBER,
        cast(null as varchar) as AUG_FIN_RECEIPT__PAYMENT_RECEIVED_INDICATOR,
        cast(null as varchar) as AUG_FIN_RECEIPT__PAYMENT_REQUEST_TIMESTAMP,
        cast(null as varchar) as AUG_FIN_RECEIPT__PAYMENT_RESPONSE_TIMESTAMP,
        t0.payinslipdate as AUG_FIN_RECEIPT__PAY_IN_SLIP_DATE,
        t0.payinslipno as AUG_FIN_RECEIPT__PAY_IN_SLIP_NUMBER,
        t0.uniquereferenceno as AUG_FIN_RECEIPT__UNIQUE_PAYMENT_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_RULE_TYPE,
        cast(null as varchar) as AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_VEHICLE_TYPE_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR,
        t0.aggrementtype as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        t0.financercode as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        t0.financerbranch as AUG_RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_BRANCH_NAME,
        cast(null as varchar) as CHANNEL_DEFINITION__CHANNEL_CATEGORY,
        cast(null as varchar) as CHANNEL_DEFINITION__CHANNEL_NAME,
        cast(null as varchar) as CHANNEL_DEFINITION__CHANNEL_TYPE,
        cast(null as varchar) as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        cast(null as varchar) as CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK,
        cast(null as varchar) as CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE,
        cast(null as varchar) as CHANNEL_FIELD_ACTIVITY__FOLLOW_UP_DATE,
        cast(null as varchar) as CHANNEL_FIELD_ACTIVITY__LEAD_REFERENCE,
        cast(null as varchar) as CHANNEL_FIELD_ACTIVITY__MEETING_PURPOSE,
        cast(null as varchar) as CHANNEL_FIELD_ACTIVITY__OUTCOME_STATUS,
        cast(null as varchar) as COMMON_GEO__LATITUDE,
        cast(null as varchar) as COMMON_GEO__LONGITUDE,
        cast(null as varchar) as COMMON_GEO__ZONE_CODE,
        cast(null as varchar) as FINTXN_RECON_INSTRUMENT__INSTRUMENT_SEQUENCE_CK,
        t0.reconciledchequeamount as FINTXN_RECON_INSTRUMENT__INSTRUMENT_AMOUNT,
        t0.reconciledchequedate as FINTXN_RECON_INSTRUMENT__INSTRUMENT_DATE,
        t0.reconciledchequeissuedby as INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME,
        t0.reconciledchequebank as INSTRUMENT_DEFINITION__BANK_NAME,
        t0.reconciledchequebranch as INSTRUMENT_DEFINITION__BRANCH_NAME,
        cast(null as varchar) as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        cast(null as varchar) as PARTY_KYC_REFERENCE__KYC_REFERENCE_NUMBER,
        cast(null as varchar) as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE,
        cast(null as varchar) as PARTY_MARKETING__CAMPAIGN_REFERENCE,
        cast(null as varchar) as PARTY_MARKETING__CAMPAIGN_RESPONSE_INDICATOR,
        t0.leadby as PARTY_MARKETING__LEAD_SOURCE,
        cast(null as varchar) as POLICY_CANCELLATION__CANCELLATION_REASON,
        t0.cancel_stat as POLICY_CANCELLATION__CANCELLATION_STATUS,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        t0.imtcode as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK,
        t0.imtcode as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE,
        t0.proposalcreatedtime as PROPOSAL_HEADER__PROPOSAL_CREATION_TIME,
        t0.proposalcreateddate as PROPOSAL_HEADER__PROPOSAL_DATE,
        cast(null as varchar) as PROPOSAL_HEADER__PROPOSAL_STATUS,
        t0.proposal_recived_date as PROPOSAL_HEADER__RECEIPT_DATE,
        cast(null as varchar) as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
        t0.proposerpaymentmode as PROPOSAL_PAYMENT__PAYMENT_MODE,
        cast(null as varchar) as PROPOSAL_SCRUTINY__QUALITY_CHECK_STATUS,
        t0.scrutiny_no as PROPOSAL_SCRUTINY__SCRUTINY_REFERENCE,
        t0.noofcleanerll as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_COUNT,
        t0.noofconductorll as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_COUNT,
        t0.noofhelperll as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_COUNT,
        t0.llnfppcount as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_COUNT,
        t0.llotherempcount as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_COUNT,
        t0.isllotheremp as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_INDICATOR,
        t0.llotheremppremium as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_PREMIUM,
        t0.noofpaiddriverll as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_COUNT,
        t0.isllpaiddriver as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_INDICATOR,
        t0.llpaiddrivpremium as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_PREMIUM,
        t0.llunnamedpasscount as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_COUNT,
        t0.isllunnamedpass as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_INDICATOR,
        t0.llunnamedpasspremium as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_PREMIUM,
        t0.noofcleanerpa as RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_COUNT,
        t0.noofconductorpa as RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_COUNT,
        t0.noofhelperpa as RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_COUNT,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), ''), nullif(nullif(trim(t0.bjazpolicyno), ''), ''), nullif(nullif(trim(t0.insproposalno), ''), ''), nullif(nullif(trim(t0.proposerpan), ''), ''), nullif(nullif(trim(t0.reconciledchequeno), ''), ''), nullif(nullif(trim(to_char(t0.bjaz_loc_code)), ''), ''), nullif(nullif(trim(to_char(t0.paymentid)), ''), ''))) is not null

    union all

    -- branch 1: BJAZ_CVTP_WS_DATA | child-key literal(s): AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION.Country Code=BANGLADESH
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'BANGLADESH' as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK,
        t0.isbangladeshcovered as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 2: BJAZ_CVTP_WS_DATA | child-key literal(s): AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION.Country Code=BHUTAN
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'BHUTAN' as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK,
        t0.isbhutancovered as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 3: BJAZ_CVTP_WS_DATA | child-key literal(s): AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION.Country Code=MALDIVES
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'MALDIVES' as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK,
        t0.ismaldivescovered as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 4: BJAZ_CVTP_WS_DATA | child-key literal(s): AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION.Country Code=NEPAL
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'NEPAL' as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK,
        t0.isnepalcovered as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 5: BJAZ_CVTP_WS_DATA | child-key literal(s): AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION.Country Code=PAKISTAN
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'PAKISTAN' as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK,
        t0.ispakistancovered as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 6: BJAZ_CVTP_WS_DATA | child-key literal(s): AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION.Country Code=SRILANKA
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'SRILANKA' as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK,
        t0.issrilankacovered as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '')) is not null

    union all

    -- branch 7: BJAZ_CVTP_WS_DATA | child-key literal(s): PARTY_KYC_REFERENCE.KYC Reference Type=VISOF_KYC_REQ_NO
    select
        null, null, null, null,
        nullif(nullif(trim(t0.proposerpan), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'VISOF_KYC_REQ_NO' as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        t0.visof_kyc_req_no as PARTY_KYC_REFERENCE__KYC_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.proposerpan), ''), '')) is not null

    union all

    -- branch 8: BJAZ_CVTP_WS_DATA | child-key literal(s): PARTY_KYC_REFERENCE.KYC Reference Type=IC_KYC_NO
    select
        null, null, null, null,
        nullif(nullif(trim(t0.proposerpan), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'IC_KYC_NO' as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        t0.ic_kyc_no as PARTY_KYC_REFERENCE__KYC_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.proposerpan), ''), '')) is not null

    union all

    -- branch 9: BJAZ_CVTP_WS_DATA | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=INSCOVERTYPE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INSCOVERTYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.inscovertype as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=MOVE_CODE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MOVE_CODE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.move_code as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(nullif(trim(to_char(t0.part_id)), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), nullif(trim(regexp_replace(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||')), '[[:space:]]+', ' ')), '')), '') as PARTY_BK,
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bank_charges as AUG_FIN_RECEIPT__BANK_CHARGES_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.partner_type as CHANNEL_DEFINITION__CHANNEL_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.zoop_ref_no as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
        null,
        t0.zoop_ref_no as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE,
        t0.campaign_code as PARTY_MARKETING__CAMPAIGN_REFERENCE,
        t0.campaign_yn as PARTY_MARKETING__CAMPAIGN_RESPONSE_INDICATOR,
        null, null, null, null, null,
        t0.imt_numbers as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK,
        t0.imt_numbers as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), nullif(trim(regexp_replace(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||')), '[[:space:]]+', ' ')), '')), ''), nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.part_id)), ''), ''))) is not null

    union all

    -- branch 12: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TRV_PLAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TRV_PLAN' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.trv_plan as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BASIC_PLAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC_PLAN' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.basic_plan as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=ADVANCED_PLAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADVANCED_PLAN' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.advanced_plan as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_RENEWAL_HIST
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null,
        nullif(nullif(trim(to_char(t0.ren_ref_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pol_can_reason as POLICY_CANCELLATION__CANCELLATION_REASON,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.qc_status as PROPOSAL_SCRUTINY__QUALITY_CHECK_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (coalesce(nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.ren_ref_no)), ''), ''))) is not null

    union all

    -- branch 16: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=VERTICAL_SEGMENT
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VERTICAL_SEGMENT' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.vertical_segment as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 17: BJAZ_MOT_TAC_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=ROAD_TYPE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ROAD_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.road_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_tac_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 18: BJAZ_MOT_TAC_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=VEH_DRIVEN_BY
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VEH_DRIVEN_BY' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.veh_driven_by as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_tac_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 19: BJAZ_MOT_TAC_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=DRIVER_EXPERIENCE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVER_EXPERIENCE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.driver_experience as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_tac_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 20: BJAZ_MOT_TAC_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=HIST_CODE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'HIST_CODE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.clm_hist_code as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_tac_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 21: BJAZ_MOT_TAC_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=INCURRED_CLM_EXP_CODE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INCURRED_CLM_EXP_CODE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.incurred_clm_exp_code as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_tac_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 22: BJAZ_MOT_TAC_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=DRIVER_QUALIFICATION_CODE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVER_QUALIFICATION_CODE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.driver_qualification_code as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_tac_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 23: BJAZ_MOT_TAC_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TAC_MAKE_CODE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TAC_MAKE_CODE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.tac_make_code as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_tac_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 24: BJAZ_MOT_WINBACK_DTLS
    select
        null,
        nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.trace_number as AUG_FIN_RECEIPT__GATEWAY_TRACE_NUMBER,
        t0.payment_received_yn as AUG_FIN_RECEIPT__PAYMENT_RECEIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.process_stage as PROPOSAL_HEADER__PROPOSAL_STATUS,
        null,
        t0.source_name as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (coalesce(nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), ''), nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), ''))) is not null

    union all

    -- branch 25: BJAZ_MOT_WINBACK_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BUSINESS_TYPE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 26: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(to_char(t0.part_id)), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(t0.receipt_no), ''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(regexp_replace(upper(nullif(trim(t0.registration_loc), '')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(regexp_replace(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||')), '[[:space:]]+', ' ')), '')), '') as PARTY_BK,
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.response_id as AUG_FIN_RECEIPT__GATEWAY_RESPONSE_IDENTIFIER,
        t0.trace_number as AUG_FIN_RECEIPT__GATEWAY_TRACE_NUMBER,
        null,
        t0.payment_req_date_time as AUG_FIN_RECEIPT__PAYMENT_REQUEST_TIMESTAMP,
        t0.payment_res_date_time as AUG_FIN_RECEIPT__PAYMENT_RESPONSE_TIMESTAMP,
        null, null, null, null, null, null, null, null, null, null,
        t0.partner_type as CHANNEL_DEFINITION__CHANNEL_CATEGORY,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.zone as COMMON_GEO__ZONE_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.campaign_code as PARTY_MARKETING__CAMPAIGN_REFERENCE,
        t0.campaign_yn as PARTY_MARKETING__CAMPAIGN_RESPONSE_INDICATOR,
        t0.source_id as PARTY_MARKETING__LEAD_SOURCE,
        null, null, null, null,
        t0.imt_numbers as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK,
        t0.imt_numbers as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(regexp_replace(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||')), '[[:space:]]+', ' ')), '')), ''), nullif(nullif(trim(regexp_replace(upper(nullif(trim(t0.registration_loc), '')), '[[:space:]]+', ' ')), ''), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(t0.receipt_no), ''), ''), nullif(nullif(trim(to_char(t0.part_id)), ''), ''))) is not null

    union all

    -- branch 27: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TRV_PLAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TRV_PLAN' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.trv_plan as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 28: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=BASIC_PLAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC_PLAN' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.basic_plan as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 29: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=ADVANCED_PLAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADVANCED_PLAN' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.advanced_plan as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 30: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): POLICY_CLASSIFICATION.Classification Type=TRV_GRP
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TRV_GRP' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.trv_grp as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 31: BJAZ_RTA_STATE_MASTER
    select
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.channel_name, '') || '|' || coalesce(t0.sub_channel_name, ''), '|')), '[[:space:]]+', ' ')), ''), '') as DISTRIBUTION_CHANNEL_BK,
        null, null, null, null, null, null,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.config_type as AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_RULE_TYPE,
        t0.vehicle_type_code as AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_VEHICLE_TYPE_CODE,
        null, null, null, null, null, null,
        t0.channel_name as CHANNEL_DEFINITION__CHANNEL_NAME,
        null,
        t0.sub_channel_name as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_rta_state_master') }} t0
    where (coalesce(nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.channel_name, '') || '|' || coalesce(t0.sub_channel_name, ''), '|')), '[[:space:]]+', ' ')), ''), ''), nullif(nullif(trim(to_char(t0.product_code)), ''), ''))) is not null

    union all

    -- branch 32: BJAZ_WAP_MOT_GS_ACT_DTLS
    select
        nullif(nullif(trim(to_char(t0.imd_code)), ''), '') as DISTRIBUTION_CHANNEL_BK,
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.latitude, '') || '|' || coalesce(t0.longitude, '') || '|' || coalesce(t0.google_add, ''), '||')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        nullif(nullif(trim(to_char(t0.branch_code)), ''), '') as ORG_UNIT_BK,
        null, null, null, null, null, null, null, null, null,
        1 as __LNK_ORG_UNIT_LOCATION,
        null, null, null, null, null,
        t0.gs_act_id as AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK,
        t0.bank_rm_dtl as AUG_CHANNEL_FIELD_ACTIVITY__BANK_RELATIONSHIP_MANAGER_DETAILS,
        t0.expect_prem as AUG_CHANNEL_FIELD_ACTIVITY__EXPECTED_PREMIUM_DISCUSSED,
        t0.health_prem as AUG_CHANNEL_FIELD_ACTIVITY__HEALTH_LINE_PREMIUM_DISCUSSED,
        t0.next_meeting as AUG_CHANNEL_FIELD_ACTIVITY__NEXT_MEETING_DATE,
        t0.non_health_prem as AUG_CHANNEL_FIELD_ACTIVITY__NON_HEALTH_LINE_PREMIUM_DISCUSSED,
        t0.designation as AUG_CHANNEL_FIELD_ACTIVITY__PARTICIPANT_DESIGNATION,
        t0.product_discus as AUG_CHANNEL_FIELD_ACTIVITY__PRODUCTS_DISCUSSED,
        t0.cust_contact as AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_CONTACT_NUMBER,
        t0.cust_name as AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.channel_flag as CHANNEL_DEFINITION__CHANNEL_CATEGORY,
        null, null, null,
        t0.gs_act_id as CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK,
        t0.gs_act_id as CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE,
        t0.follow_up_date as CHANNEL_FIELD_ACTIVITY__FOLLOW_UP_DATE,
        t0.lap_no as CHANNEL_FIELD_ACTIVITY__LEAD_REFERENCE,
        t0.reason as CHANNEL_FIELD_ACTIVITY__MEETING_PURPOSE,
        t0.status as CHANNEL_FIELD_ACTIVITY__OUTCOME_STATUS,
        t0.latitude as COMMON_GEO__LATITUDE,
        t0.longitude as COMMON_GEO__LONGITUDE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_gs_act_dtls') }} t0
    where (coalesce(nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.latitude, '') || '|' || coalesce(t0.longitude, '') || '|' || coalesce(t0.google_add, ''), '||')), '[[:space:]]+', ' ')), ''), ''), nullif(nullif(trim(to_char(t0.branch_code)), ''), ''), nullif(nullif(trim(to_char(t0.imd_code)), ''), ''))) is not null

    union all

    -- branch 33: RTA_CLUSTER_PREFERRED_DECLINE
    select
        nullif(nullif(trim(t0.agent_channel), ''), '') as DISTRIBUTION_CHANNEL_BK,
        null, null,
        nullif(nullif(trim(to_char(t0.location_code)), ''), '') as ORG_UNIT_BK,
        null, null, null, null, null, null,
        1 as __LNK_CHANNEL_ORG_UNIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_channel as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rta_cluster_preferred_decline') }} t0
    where (coalesce(nullif(nullif(trim(t0.agent_channel), ''), ''), nullif(nullif(trim(to_char(t0.location_code)), ''), ''))) is not null

)

select
    DISTRIBUTION_CHANNEL_BK,
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    PAYMENT_INSTRUMENT_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    __LNK_CHANNEL_ORG_UNIT,
    __LNK_FINTXN_INSTRUMENT,
    __LNK_FINTXN_POLICY,
    __LNK_ORG_UNIT_LOCATION,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_PAYMENT_INSTRUMENT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_PROPOSAL_POLICY,
    __LNK_PROPOSAL_RISK_OBJECT,
    AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__BANK_RELATIONSHIP_MANAGER_DETAILS) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__BANK_RELATIONSHIP_MANAGER_DETAILS,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__EXPECTED_PREMIUM_DISCUSSED) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__EXPECTED_PREMIUM_DISCUSSED,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__HEALTH_LINE_PREMIUM_DISCUSSED) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__HEALTH_LINE_PREMIUM_DISCUSSED,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__NEXT_MEETING_DATE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__NEXT_MEETING_DATE,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__NON_HEALTH_LINE_PREMIUM_DISCUSSED) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__NON_HEALTH_LINE_PREMIUM_DISCUSSED,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__PARTICIPANT_DESIGNATION) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__PARTICIPANT_DESIGNATION,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__PRODUCTS_DISCUSSED) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__PRODUCTS_DISCUSSED,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_CONTACT_NUMBER) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_CONTACT_NUMBER,
    first_value(AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_NAME) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_NAME,
    first_value(AUG_FIN_RECEIPT__BANK_CHARGES_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__BANK_CHARGES_AMOUNT,
    first_value(AUG_FIN_RECEIPT__GATEWAY_RESPONSE_IDENTIFIER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__GATEWAY_RESPONSE_IDENTIFIER,
    first_value(AUG_FIN_RECEIPT__GATEWAY_TRACE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__GATEWAY_TRACE_NUMBER,
    first_value(AUG_FIN_RECEIPT__PAYMENT_RECEIVED_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__PAYMENT_RECEIVED_INDICATOR,
    first_value(AUG_FIN_RECEIPT__PAYMENT_REQUEST_TIMESTAMP) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__PAYMENT_REQUEST_TIMESTAMP,
    first_value(AUG_FIN_RECEIPT__PAYMENT_RESPONSE_TIMESTAMP) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__PAYMENT_RESPONSE_TIMESTAMP,
    first_value(AUG_FIN_RECEIPT__PAY_IN_SLIP_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__PAY_IN_SLIP_DATE,
    first_value(AUG_FIN_RECEIPT__PAY_IN_SLIP_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__PAY_IN_SLIP_NUMBER,
    first_value(AUG_FIN_RECEIPT__UNIQUE_PAYMENT_REFERENCE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__UNIQUE_PAYMENT_REFERENCE_NUMBER,
    first_value(AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_RULE_TYPE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_RULE_TYPE,
    first_value(AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_VEHICLE_TYPE_CODE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DISTRIBUTION_RULES__RTA_CONFIGURATION_VEHICLE_TYPE_CODE,
    AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK,
    first_value(AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COUNTRY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR,
    AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
    AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
    first_value(AUG_RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_BRANCH_NAME) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_BRANCH_NAME,
    first_value(CHANNEL_DEFINITION__CHANNEL_CATEGORY) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__CHANNEL_CATEGORY,
    first_value(CHANNEL_DEFINITION__CHANNEL_NAME) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__CHANNEL_NAME,
    first_value(CHANNEL_DEFINITION__CHANNEL_TYPE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__CHANNEL_TYPE,
    first_value(CHANNEL_DEFINITION__SUB_CHANNEL_CODE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
    CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK,
    first_value(CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE,
    first_value(CHANNEL_FIELD_ACTIVITY__FOLLOW_UP_DATE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_FIELD_ACTIVITY__FOLLOW_UP_DATE,
    first_value(CHANNEL_FIELD_ACTIVITY__LEAD_REFERENCE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_FIELD_ACTIVITY__LEAD_REFERENCE,
    first_value(CHANNEL_FIELD_ACTIVITY__MEETING_PURPOSE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_FIELD_ACTIVITY__MEETING_PURPOSE,
    first_value(CHANNEL_FIELD_ACTIVITY__OUTCOME_STATUS) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_FIELD_ACTIVITY__OUTCOME_STATUS,
    first_value(COMMON_GEO__LATITUDE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__LATITUDE,
    first_value(COMMON_GEO__LONGITUDE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__LONGITUDE,
    first_value(COMMON_GEO__ZONE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__ZONE_CODE,
    FINTXN_RECON_INSTRUMENT__INSTRUMENT_SEQUENCE_CK,
    first_value(FINTXN_RECON_INSTRUMENT__INSTRUMENT_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_RECON_INSTRUMENT__INSTRUMENT_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_RECON_INSTRUMENT__INSTRUMENT_AMOUNT,
    first_value(FINTXN_RECON_INSTRUMENT__INSTRUMENT_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_RECON_INSTRUMENT__INSTRUMENT_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_RECON_INSTRUMENT__INSTRUMENT_DATE,
    first_value(INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__ACCOUNT_HOLDER_NAME,
    first_value(INSTRUMENT_DEFINITION__BANK_NAME) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__BANK_NAME,
    first_value(INSTRUMENT_DEFINITION__BRANCH_NAME) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__BRANCH_NAME,
    PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK,
    first_value(PARTY_KYC_REFERENCE__KYC_REFERENCE_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC_REFERENCE__KYC_REFERENCE_NUMBER,
    first_value(PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE) ignore nulls over (partition by PARTY_BK, PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE,
    first_value(PARTY_MARKETING__CAMPAIGN_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_MARKETING__CAMPAIGN_REFERENCE,
    first_value(PARTY_MARKETING__CAMPAIGN_RESPONSE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_MARKETING__CAMPAIGN_RESPONSE_INDICATOR,
    first_value(PARTY_MARKETING__LEAD_SOURCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_MARKETING__LEAD_SOURCE,
    first_value(POLICY_CANCELLATION__CANCELLATION_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_REASON,
    first_value(POLICY_CANCELLATION__CANCELLATION_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_STATUS,
    POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    first_value(POLICY_CLASSIFICATION__CLASSIFICATION_VALUE) ignore nulls over (partition by POLICY_BK, POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
    POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK,
    first_value(POLICY_CLAUSE_ATTACHED__CLAUSE_CODE) ignore nulls over (partition by POLICY_BK, POLICY_CLAUSE_ATTACHED__CLAUSE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLAUSE_ATTACHED__CLAUSE_CODE,
    first_value(PROPOSAL_HEADER__PROPOSAL_CREATION_TIME) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__PROPOSAL_CREATION_TIME,
    first_value(PROPOSAL_HEADER__PROPOSAL_DATE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__PROPOSAL_DATE,
    first_value(PROPOSAL_HEADER__PROPOSAL_STATUS) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__PROPOSAL_STATUS,
    first_value(PROPOSAL_HEADER__RECEIPT_DATE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__RECEIPT_DATE,
    first_value(PROPOSAL_HEADER__SUBMISSION_CHANNEL) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
    first_value(PROPOSAL_PAYMENT__PAYMENT_MODE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_PAYMENT__PAYMENT_MODE,
    first_value(PROPOSAL_SCRUTINY__QUALITY_CHECK_STATUS) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_SCRUTINY__QUALITY_CHECK_STATUS,
    first_value(PROPOSAL_SCRUTINY__SCRUTINY_REFERENCE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_SCRUTINY__SCRUTINY_REFERENCE,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CLEANER_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_CONDUCTOR_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_HELPER_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_NON_FARE_PAYING_PASSENGER_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_INDICATOR,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_OTHER_EMPLOYEE_PREMIUM,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_INDICATOR,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_PAID_DRIVER_PREMIUM,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_INDICATOR,
    first_value(RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__LEGAL_LIABILITY_UNNAMED_PASSENGER_PREMIUM,
    first_value(RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__PA_CLEANER_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__PA_CONDUCTOR_COUNT,
    first_value(RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_LIABILITY_ADDON__PA_HELPER_COUNT,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on DISTRIBUTION_CHANNEL_BK (SAT_MOTOR_AUG_CHANNEL_FIELD_ACTIVITY, SAT_CHANNEL_FIELD_ACTIVITY):
    -- one load time per DISTRIBUTION_CHANNEL_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_CHANNEL_FIELD_ACTIVITY__BANK_RELATIONSHIP_MANAGER_DETAILS, m.AUG_CHANNEL_FIELD_ACTIVITY__EXPECTED_PREMIUM_DISCUSSED, m.AUG_CHANNEL_FIELD_ACTIVITY__HEALTH_LINE_PREMIUM_DISCUSSED, m.AUG_CHANNEL_FIELD_ACTIVITY__NEXT_MEETING_DATE, m.AUG_CHANNEL_FIELD_ACTIVITY__NON_HEALTH_LINE_PREMIUM_DISCUSSED, m.AUG_CHANNEL_FIELD_ACTIVITY__PARTICIPANT_DESIGNATION, m.AUG_CHANNEL_FIELD_ACTIVITY__PRODUCTS_DISCUSSED, m.AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_CONTACT_NUMBER, m.AUG_CHANNEL_FIELD_ACTIVITY__PROSPECT_NAME, m.CHANNEL_FIELD_ACTIVITY__ACTIVITY_REFERENCE, m.CHANNEL_FIELD_ACTIVITY__FOLLOW_UP_DATE, m.CHANNEL_FIELD_ACTIVITY__LEAD_REFERENCE, m.CHANNEL_FIELD_ACTIVITY__MEETING_PURPOSE, m.CHANNEL_FIELD_ACTIVITY__OUTCOME_STATUS) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.DISTRIBUTION_CHANNEL_BK) as DISTRIBUTION_CHANNEL_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on RISK_OBJECT_BK (SAT_MOTOR_AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION, SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST):
    -- one load time per RISK_OBJECT_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_RISK_MOTOR_GEOGRAPHICAL_EXTENSION__COVERED_INDICATOR, m.AUG_RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_BRANCH_NAME) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.RISK_OBJECT_BK) as RISK_OBJECT_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on FINANCIAL_TRANSACTION_BK (SAT_FINTXN_RECON_INSTRUMENT):
    -- one load time per FINANCIAL_TRANSACTION_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.FINTXN_RECON_INSTRUMENT__INSTRUMENT_AMOUNT, m.FINTXN_RECON_INSTRUMENT__INSTRUMENT_DATE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.FINANCIAL_TRANSACTION_BK) as FINANCIAL_TRANSACTION_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on PARTY_BK (SAT_PARTY_KYC_REFERENCE):
    -- one load time per PARTY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.PARTY_KYC_REFERENCE__KYC_REFERENCE_NUMBER, m.PARTY_KYC_REFERENCE__KYC_REFERENCE_TYPE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on POLICY_BK (SAT_POLICY_CLASSIFICATION, SAT_POLICY_CLAUSE_ATTACHED):
    -- one load time per POLICY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.POLICY_CLASSIFICATION__CLASSIFICATION_VALUE, m.POLICY_CLAUSE_ATTACHED__CLAUSE_CODE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME
from merged m
