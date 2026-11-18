-- CENTRAL VIEW v11_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BGIL_MOTOR_WS_PREMIUM_DTLS_EQM
--   BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOT_CLM_TRANS_EXTN
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_WAP_MOT_ADDONPKG
--   BJAZ_WAP_MOT_STP_RATE_SUMM
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CHANNEL_DIGITAL_INTEGRATION
--   SAT_AUG_COMMON_CONTACT
--   SAT_AUG_FINTXN_CHANNEL_AUTHORISATION
--   SAT_AUG_FINTXN_HEADER
--   SAT_AUG_FINTXN_PREMIUM
--   SAT_AUG_PARTY_CONTACT_ADDRESS_LINK
--   SAT_AUG_PARTY_DIGITAL_IDENTITY
--   SAT_AUG_PARTY_DIGITAL_JOURNEY_STAGE
--   SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_AUG_PARTY_INTERACTION_EVENT
--   SAT_AUG_PARTY_MARKETING
--   SAT_AUG_PARTY_ONBOARDING_JOURNEY
--   SAT_AUG_PARTY_PREFERENCE_PROFILE
--   SAT_AUG_PARTY_VEHICLE_OWNER
--   SAT_AUG_POLICY_INTERMEDIARY_SPLIT
--   SAT_AUG_POLICY_TERMS
--   SAT_AUG_RISK_MOTOR_CPA
--   SAT_AUG_RISK_PERSON_STUDENT_PA
--   SAT_COMMON_COMMUNICATION_PREFERENCE
--   SAT_FINTXN_HEADER
--   SAT_FINTXN_PREMIUM
--   SAT_FINTXN_TAX
--   SAT_FIN_CHARGE_RATE
--   SAT_LEAD_ATTRIBUTION
--   SAT_LNK_ROLE_AGENT
--   SAT_LNK_ROLE_EMPLOYEE
--   SAT_LNK_ROLE_POSP
--   SAT_PARTY_BANKING
--   SAT_PARTY_CORRESPONDENCE
--   SAT_PARTY_DIGITAL_IDENTITY
--   SAT_PARTY_EMPLOYMENT
--   SAT_PARTY_FINANCIAL_PROFILE
--   SAT_PARTY_INTERACTION_EVENT
--   SAT_POLICY_DOC_CHECKLIST
--   SAT_POLICY_LIFECYCLE
--   SAT_PROPOSAL_UNDERWRITING
--   SAT_QUOTE_COMPARISON
--   SAT_RISK_PERSON_STUDENT_PA
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CASE_POLICY
--   LNK_CHANNEL_ORG_UNIT
--   LNK_FINTXN_POLICY
--   LNK_PARTY_LOCATION
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_LOCATION
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
--   LNK_PROPOSAL_RISK_OBJECT
--   LNK_QUOTE_PRODUCT
--   LNK_QUOTE_PROPOSAL
--   LNK_QUOTE_RISK_OBJECT
--   LNK_RISK_OBJECT_LOCATION
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        cast(null as varchar) as CASE_BK,
        nullif(nullif(trim(t0.imd_code), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(to_char(t0.postal_code), ''), '|')))), '') as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_CASE_POLICY,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        1 as __LNK_FINTXN_POLICY,
        cast(null as number) as __LNK_PARTY_LOCATION,
        1 as __LNK_POLICY_CHANNEL,
        1 as __LNK_POLICY_LOCATION,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_PROPOSAL_POLICY,
        cast(null as number) as __LNK_PROPOSAL_PRODUCT,
        cast(null as number) as __LNK_PROPOSAL_RISK_OBJECT,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as number) as __LNK_QUOTE_PROPOSAL,
        cast(null as number) as __LNK_QUOTE_RISK_OBJECT,
        1 as __LNK_RISK_OBJECT_LOCATION,
        cast(null as varchar) as AUG_CHANNEL_DIGITAL_INTEGRATION__PARTNER_REQUEST_REFERENCE,
        cast(null as varchar) as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        cast(null as varchar) as AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        cast(null as varchar) as AUG_COMMON_CONTACT__ALTERNATE_LANDLINE_NUMBER,
        cast(null as varchar) as AUG_COMMON_CONTACT__PREFERRED_CONTACT_DATE,
        t0.pin_date as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_DATE,
        t0.pin_no as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_NUMBER,
        t0.pin_status as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_STATUS,
        t0.sahaj_req_id as AUG_FINTXN_HEADER__CHANNEL_REQUEST_REFERENCE,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__FINAL_PREMIUM,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__IMT_ENDORSEMENT_CODE_LIST,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__NET_PREMIUM_COMPONENT,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__NO_CLAIM_BONUS_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__TOTAL_ACT_LIABILITY_PREMIUM,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__TOTAL_IEV_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__TOTAL_OWN_DAMAGE_PREMIUM,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__BROWSER_NAME,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__CLIENT_IP_ADDRESS,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__CONNECTION_BANDWIDTH,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__FORWARDED_IP_ADDRESS,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__MACHINE_IP_ADDRESS,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__PROXY_IP_ADDRESS,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__THIRD_IP_ADDRESS,
        cast(null as varchar) as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CODE_CK,
        cast(null as varchar) as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        cast(null as varchar) as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FOUR_WHEELER_OWNED_COUNT,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__TWO_WHEELER_OWNED_COUNT,
        cast(null as varchar) as AUG_PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK,
        cast(null as varchar) as AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE_CK,
        cast(null as varchar) as AUG_PARTY_INTERACTION_EVENT__FOLLOW_UP_TIME,
        cast(null as varchar) as AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE,
        cast(null as varchar) as AUG_PARTY_INTERACTION_EVENT__INTERACTION_TIME,
        cast(null as varchar) as AUG_PARTY_MARKETING__PROFILING_DISCLOSURE_OPTED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_MARKETING__PROMOTION_NUMBER,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__JOURNEY_PAGE_URL,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__CALLBACK_REQUESTED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_DATE,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_TIME,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_CONTACT_DATE,
        cast(null as varchar) as AUG_PARTY_VEHICLE_OWNER__FOUR_WHEELER_OWNED_COUNT,
        cast(null as varchar) as AUG_PARTY_VEHICLE_OWNER__TWO_WHEELER_OWNED_COUNT,
        cast(null as varchar) as AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        cast(null as varchar) as AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE,
        cast(null as varchar) as AUG_POLICY_TERMS__CO_PAYMENT_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_TERMS__CO_PAYMENT_OPTED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE,
        cast(null as varchar) as AUG_RISK_MOTOR_CPA__COMPULSORY_PA_DEFAULT_INDICATOR,
        cast(null as varchar) as AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_CONTACT_NUMBER,
        cast(null as varchar) as AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_NAME,
        cast(null as varchar) as AUG_RISK_PERSON_STUDENT_PA__STUDENT_REMARKS,
        cast(null as varchar) as COMMON_COMMUNICATION_PREFERENCE__CALL_OPT_IN_INDICATOR,
        cast(null as varchar) as FINTXN_HEADER__NARRATION,
        cast(null as varchar) as FINTXN_HEADER__ORG_UNIT_CODE,
        t0.order_number as FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE,
        cast(null as varchar) as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_CHANNEL,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_DATE,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
        t0.pservice_type as FINTXN_HEADER__TRANSACTION_TYPE,
        t0.payment_mode as FINTXN_PREMIUM__COLLECTION_MODE,
        cast(null as varchar) as FINTXN_PREMIUM__COLLECTION_STATUS,
        cast(null as varchar) as FINTXN_PREMIUM__DISCOUNT_AMOUNT,
        cast(null as varchar) as FINTXN_PREMIUM__GROSS_PREMIUM,
        cast(null as varchar) as FINTXN_PREMIUM__LOADING_AMOUNT,
        cast(null as varchar) as FINTXN_PREMIUM__NET_PREMIUM,
        cast(null as varchar) as FINTXN_PREMIUM__STAMP_DUTY_AMOUNT,
        cast(null as varchar) as FINTXN_TAX__TAX_TYPE_CK,
        cast(null as varchar) as FINTXN_TAX__SERVICE_TAX_AMOUNT,
        cast(null as varchar) as FIN_CHARGE_RATE__CHARGE_TYPE_CK,
        cast(null as varchar) as FIN_CHARGE_RATE__CHARGE_RATE,
        cast(null as varchar) as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        cast(null as varchar) as LEAD_ATTRIBUTION__LEAD_REFERENCE,
        cast(null as varchar) as LEAD_ATTRIBUTION__PARAMETER_VALUE,
        cast(null as varchar) as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_AGENT__AGENT_CODE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        cast(null as varchar) as LNK_ROLE_POSP__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_POSP__POSP_CODE,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        cast(null as varchar) as PARTY_BANKING__BANK_NAME,
        cast(null as varchar) as PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK,
        cast(null as varchar) as PARTY_CORRESPONDENCE__TEMPLATE_REFERENCE,
        cast(null as varchar) as PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER,
        cast(null as varchar) as PARTY_EMPLOYMENT__INDUSTRY_SECTOR,
        cast(null as varchar) as PARTY_FINANCIAL_PROFILE__CIBIL_SCORE,
        cast(null as varchar) as PARTY_FINANCIAL_PROFILE__CREDIT_SCORE_DATE,
        cast(null as varchar) as PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK,
        cast(null as varchar) as PARTY_INTERACTION_EVENT__FOLLOW_UP_DATE,
        cast(null as varchar) as PARTY_INTERACTION_EVENT__INTERACTION_DATE,
        cast(null as varchar) as POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as POLICY_DOC_CHECKLIST__VERIFICATION_STATUS,
        cast(null as varchar) as POLICY_LIFECYCLE__ASSIGNEE_REFERENCE,
        cast(null as varchar) as PROPOSAL_UNDERWRITING__REFERRAL_DATE,
        cast(null as varchar) as PROPOSAL_UNDERWRITING__REFERRAL_REASON,
        cast(null as varchar) as QUOTE_COMPARISON__OPTION_CODE_CK,
        cast(null as varchar) as QUOTE_COMPARISON__PREMIUM_OPTION,
        cast(null as varchar) as RISK_PERSON_STUDENT_PA__COURSE_DURATION_MONTHS,
        cast(null as varchar) as RISK_PERSON_STUDENT_PA__COURSE_NAME,
        cast(null as varchar) as RISK_PERSON_STUDENT_PA__INSTITUTION_ADDRESS,
        cast(null as varchar) as RISK_PERSON_STUDENT_PA__INSTITUTION_NAME,
        cast(null as varchar) as RISK_PERSON_STUDENT_PA__SEMESTER_NUMBER,
        cast(null as varchar) as RISK_PERSON_STUDENT_PA__STUDENT_FITNESS_STATUS,
        cast(null as varchar) as RISK_PERSON_STUDENT_PA__TUITION_FEE_AMOUNT,
        cast(null as varchar) as RISK_PERSON_STUDENT_PA__TUITION_FEE_PAYER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(to_char(t0.postal_code), ''), '|')))), ''), nullif(nullif(trim(t0.imd_code), ''), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.product_code)), ''), ''), nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), ''))) is not null

    union all

    -- branch 1: BGIL_MOTOR_WEBSERVICE_INFO_EQM | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null, null, null,
        nullif(nullif('SP:' || nullif(trim(t0.sp_code), ''), 'SP:'), '') as PARTY_BK,
        null, null, null, null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        t0.sp_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(nullif('SP:' || nullif(trim(t0.sp_code), ''), 'SP:'), '')) is not null

    union all

    -- branch 2: BGIL_MOTOR_WEBSERVICE_INFO_EQM | child-key literal(s): LNK_ROLE_POSP.Role Type=POSP
    select
        null, null, null, null, null,
        nullif(nullif('POSP:' || nullif(trim(t0.posp_code), ''), 'POSP:'), '') as PARTY_BK,
        null, null, null, null, null,
        'POSP' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'POSP' as LNK_ROLE_POSP__ROLE_TYPE_CK,
        t0.posp_code as LNK_ROLE_POSP__POSP_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(nullif('POSP:' || nullif(trim(t0.posp_code), ''), 'POSP:'), '')) is not null

    union all

    -- branch 3: BGIL_MOTOR_WS_PREMIUM_DTLS_EQM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.coll_premium as AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT,
        t0.final_premium as AUG_FINTXN_PREMIUM__FINAL_PREMIUM,
        t0.imt_out as AUG_FINTXN_PREMIUM__IMT_ENDORSEMENT_CODE_LIST,
        t0.net_premium as AUG_FINTXN_PREMIUM__NET_PREMIUM_COMPONENT,
        t0.ncb_amt as AUG_FINTXN_PREMIUM__NO_CLAIM_BONUS_AMOUNT,
        t0.total_act_premium as AUG_FINTXN_PREMIUM__TOTAL_ACT_LIABILITY_PREMIUM,
        t0.total_iev as AUG_FINTXN_PREMIUM__TOTAL_IEV_AMOUNT,
        t0.total_od_premium as AUG_FINTXN_PREMIUM__TOTAL_OWN_DAMAGE_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.module_from as FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE,
        null, null, null, null, null, null, null,
        t0.sp_disc as FINTXN_PREMIUM__DISCOUNT_AMOUNT,
        t0.total_premium as FINTXN_PREMIUM__GROSS_PREMIUM,
        t0.add_load_prem as FINTXN_PREMIUM__LOADING_AMOUNT,
        t0.total_net_premium as FINTXN_PREMIUM__NET_PREMIUM,
        t0.stamp_duty as FINTXN_PREMIUM__STAMP_DUTY_AMOUNT,
        null,
        t0.service_tax as FINTXN_TAX__SERVICE_TAX_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_premium_dtls_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 4: BGIL_MOTOR_WS_PREMIUM_SUMMARY_EQM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.module_from as FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_premium_summary_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 5: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        null,
        nullif(nullif(trim(t0.imd_code), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(to_char(t0.postal_code), ''), '|')))), '') as LOCATION_BK,
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null,
        1 as __LNK_FINTXN_POLICY,
        null,
        1 as __LNK_POLICY_CHANNEL,
        1 as __LNK_POLICY_LOCATION,
        null,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null, null, null, null, null,
        1 as __LNK_RISK_OBJECT_LOCATION,
        null, null, null, null, null,
        t0.pin_date as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_DATE,
        t0.pin_no as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_NUMBER,
        t0.pin_status as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_STATUS,
        t0.sahaj_req_id as AUG_FINTXN_HEADER__CHANNEL_REQUEST_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.order_number as FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE,
        null, null, null, null,
        t0.pservice_type as FINTXN_HEADER__TRANSACTION_TYPE,
        t0.payment_mode as FINTXN_PREMIUM__COLLECTION_MODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(md5(normalise(upper(nullif(coalesce(t0.city, '') || '|' || coalesce(to_char(t0.postal_code), ''), '|')))), ''), nullif(nullif(trim(t0.imd_code), ''), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.product_code)), ''), ''), nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), ''))) is not null

    union all

    -- branch 6: BJAZ_MOTOR_WEBSERVICE_INFO | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null, null, null,
        nullif(nullif('SP:' || nullif(trim(t0.sp_code), ''), 'SP:'), '') as PARTY_BK,
        null, null, null, null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        t0.sp_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(nullif('SP:' || nullif(trim(t0.sp_code), ''), 'SP:'), '')) is not null

    union all

    -- branch 7: BJAZ_MOTOR_WEBSERVICE_INFO | child-key literal(s): LNK_ROLE_POSP.Role Type=POSP
    select
        null, null, null, null, null,
        nullif(nullif('POSP:' || nullif(trim(t0.posp_code), ''), 'POSP:'), '') as PARTY_BK,
        null, null, null, null, null,
        'POSP' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'POSP' as LNK_ROLE_POSP__ROLE_TYPE_CK,
        t0.posp_code as LNK_ROLE_POSP__POSP_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(nullif('POSP:' || nullif(trim(t0.posp_code), ''), 'POSP:'), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_CLM_TRANS_EXTN
    select
        null, null,
        nullif(nullif('CLMTXN:' || nullif(trim(to_char(t0.trans_no)), ''), 'CLMTXN:'), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.reference_text as FINTXN_HEADER__NARRATION,
        t0.pay_location as FINTXN_HEADER__ORG_UNIT_CODE,
        null, null, null, null,
        t0.event_code as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
        null, null, null, null, null, null, null, null, null,
        t0.service_tax_amt as FINTXN_TAX__SERVICE_TAX_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_trans_extn') }} t0
    where (nullif(nullif('CLMTXN:' || nullif(trim(to_char(t0.trans_no)), ''), 'CLMTXN:'), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): AUG_PARTY_CONTACT_ADDRESS_LINK.Address Usage Type=DISPATCH_ADDRESS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_area, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '|||||')))), '') as LOCATION_BK,
        null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'DISPATCH_ADDRESS' as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        t0.same_mailing_address as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), ''), nullif(md5(normalise(upper(nullif(coalesce(t0.disp_address_line1, '') || '|' || coalesce(t0.disp_address_line2, '') || '|' || coalesce(t0.disp_area, '') || '|' || coalesce(t0.disp_city, '') || '|' || coalesce(t0.disp_state, '') || '|' || coalesce(t0.disppostcode, ''), '|||||')))), ''))) is not null

    union all

    -- branch 10: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null,
        nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(t0.product_4digit_code), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(to_char(t0.reference_id)), ''), '') as PROPOSAL_BK,
        nullif(nullif(trim(t0.quote_ref_no), ''), '') as QUOTE_BK,
        nullif(md5(normalise(upper(nullif(coalesce(t0.student_name, '') || '|' || coalesce(t0.school_name, '') || '|' || coalesce(t0.course, ''), '||')))), '') as RISK_OBJECT_BK,
        null, null, null,
        1 as __LNK_FINTXN_POLICY,
        null, null, null, null,
        1 as __LNK_POLICY_PRODUCT,
        null,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        null,
        1 as __LNK_QUOTE_PRODUCT,
        1 as __LNK_QUOTE_PROPOSAL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.data_source as AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK,
        t0.browser as AUG_PARTY_DIGITAL_IDENTITY__BROWSER_NAME,
        null,
        t0.bandwidth as AUG_PARTY_DIGITAL_IDENTITY__CONNECTION_BANDWIDTH,
        null,
        t0.machine_ip as AUG_PARTY_DIGITAL_IDENTITY__MACHINE_IP_ADDRESS,
        t0.proxy_ip as AUG_PARTY_DIGITAL_IDENTITY__PROXY_IP_ADDRESS,
        t0.third_ip as AUG_PARTY_DIGITAL_IDENTITY__THIRD_IP_ADDRESS,
        null, null, null, null, null, null,
        t0.call_id as AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE_CK,
        null,
        t0.call_id as AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE,
        t0.ivrs_time as AUG_PARTY_INTERACTION_EVENT__INTERACTION_TIME,
        null, null, null,
        t0.callme as AUG_PARTY_PREFERENCE_PROFILE__CALLBACK_REQUESTED_INDICATOR,
        t0.details_pikup_date as AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_DATE,
        t0.details_pikup_time as AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_TIME,
        t0.prefereddate as AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_CONTACT_DATE,
        t0.no_of_vehicle_4w as AUG_PARTY_VEHICLE_OWNER__FOUR_WHEELER_OWNED_COUNT,
        t0.no_of_vehicle_2w as AUG_PARTY_VEHICLE_OWNER__TWO_WHEELER_OWNED_COUNT,
        null, null, null,
        t0.copayment_yn as AUG_POLICY_TERMS__CO_PAYMENT_OPTED_INDICATOR,
        null, null,
        t0.family_doc_tel as AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_CONTACT_NUMBER,
        t0.family_doc as AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_NAME,
        t0.student_remarks as AUG_RISK_PERSON_STUDENT_PA__STUDENT_REMARKS,
        null, null, null,
        t0.response_id as FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE,
        null,
        t0.payment_gateway as FINTXN_HEADER__TRANSACTION_CHANNEL,
        t0.payment_req_date_time as FINTXN_HEADER__TRANSACTION_DATE,
        null, null,
        t0.payment_mode as FINTXN_PREMIUM__COLLECTION_MODE,
        null, null, null, null, null, null, null,
        t0.service_tax_amt as FINTXN_TAX__SERVICE_TAX_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payment_bank_name as PARTY_BANKING__BANK_NAME,
        t0.message_code as PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK,
        t0.message_code as PARTY_CORRESPONDENCE__TEMPLATE_REFERENCE,
        null, null,
        t0.prof_sector as PARTY_EMPLOYMENT__INDUSTRY_SECTOR,
        t0.cibil_score as PARTY_FINANCIAL_PROFILE__CIBIL_SCORE,
        t0.cibil_date as PARTY_FINANCIAL_PROFILE__CREDIT_SCORE_DATE,
        null, null,
        t0.ivrs_date as PARTY_INTERACTION_EVENT__INTERACTION_DATE,
        null,
        t0.upload_invoice_status as POLICY_DOC_CHECKLIST__VERIFICATION_STATUS,
        t0.assigne_name as POLICY_LIFECYCLE__ASSIGNEE_REFERENCE,
        t0.refer_date as PROPOSAL_UNDERWRITING__REFERRAL_DATE,
        t0.referral_reason as PROPOSAL_UNDERWRITING__REFERRAL_REASON,
        null, null,
        t0.course_duration as RISK_PERSON_STUDENT_PA__COURSE_DURATION_MONTHS,
        t0.course as RISK_PERSON_STUDENT_PA__COURSE_NAME,
        t0.school_address as RISK_PERSON_STUDENT_PA__INSTITUTION_ADDRESS,
        t0.school_name as RISK_PERSON_STUDENT_PA__INSTITUTION_NAME,
        t0.semester_no as RISK_PERSON_STUDENT_PA__SEMESTER_NUMBER,
        t0.student_fitness as RISK_PERSON_STUDENT_PA__STUDENT_FITNESS_STATUS,
        t0.tution_fee as RISK_PERSON_STUDENT_PA__TUITION_FEE_AMOUNT,
        t0.tutionfee_by as RISK_PERSON_STUDENT_PA__TUITION_FEE_PAYER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), ''), nullif(md5(normalise(upper(nullif(coalesce(t0.student_name, '') || '|' || coalesce(t0.school_name, '') || '|' || coalesce(t0.course, ''), '||')))), ''), nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(t0.product_4digit_code), ''), ''), nullif(nullif(trim(t0.quote_ref_no), ''), ''), nullif(nullif(trim(to_char(t0.reference_id)), ''), ''))) is not null

    union all

    -- branch 11: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=PRODUCT
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PRODUCT' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.product_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=PREMIUM
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PREMIUM' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.premium_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=CUSTOMER
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'CUSTOMER' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.customer_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=PAYMENT
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PAYMENT' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.payment_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=POLICY
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'POLICY' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.policy_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 16: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=CONTACT
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'CONTACT' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.contact_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 17: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): FIN_CHARGE_RATE.Charge Type=SERVICE_CHARGE_RATE
    select
        null, null,
        nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'SERVICE_CHARGE_RATE' as FIN_CHARGE_RATE__CHARGE_TYPE_CK,
        t0.service_charge_rate as FIN_CHARGE_RATE__CHARGE_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), '')) is not null

    union all

    -- branch 18: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): LEAD_ATTRIBUTION.Attribution Parameter=URL
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'URL' as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        null,
        t0.url as LEAD_ATTRIBUTION__PARAMETER_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 19: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): LEAD_ATTRIBUTION.Attribution Parameter=QUALITY_EXT_ID
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'QUALITY_EXT_ID' as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        null,
        t0.quality_ext_id as LEAD_ATTRIBUTION__PARAMETER_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 20: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): LEAD_ATTRIBUTION.Attribution Parameter=CAMPAIGN_GOOGLE_CODE
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'CAMPAIGN_GOOGLE_CODE' as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        null,
        t0.campaign_google_code as LEAD_ATTRIBUTION__PARAMETER_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 21: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): LEAD_ATTRIBUTION.Attribution Parameter=VISITOR_ID
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'VISITOR_ID' as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        null,
        t0.visitor_id as LEAD_ATTRIBUTION__PARAMETER_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 22: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): LEAD_ATTRIBUTION.Attribution Parameter=LMS_KEY
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'LMS_KEY' as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        t0.lms_key as LEAD_ATTRIBUTION__LEAD_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 23: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): LNK_ROLE_AGENT.Role Type=AGENT
    select
        null, null, null, null, null,
        nullif(nullif(trim(t0.sub_agent_code), ''), '') as PARTY_BK,
        null, null, null, null, null,
        'AGENT' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AGENT' as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        t0.sub_agent_code as LNK_ROLE_AGENT__AGENT_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.sub_agent_code), ''), '')) is not null

    union all

    -- branch 24: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): LNK_ROLE_AGENT.Role Type=AGENT
    select
        null, null, null, null, null,
        nullif(nullif(trim(t0.main_agent_code), ''), '') as PARTY_BK,
        null, null, null, null, null,
        'AGENT' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AGENT' as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        t0.main_agent_code as LNK_ROLE_AGENT__AGENT_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.main_agent_code), ''), '')) is not null

    union all

    -- branch 25: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null, null, null,
        nullif(nullif('EMP:' || nullif(trim(to_char(t0.emp_code)), ''), 'EMP:'), '') as PARTY_BK,
        null, null, null, null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        t0.emp_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif('EMP:' || nullif(trim(to_char(t0.emp_code)), ''), 'EMP:'), '')) is not null

    union all

    -- branch 26: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null, null, null, null,
        nullif(nullif('RVMP:' || nullif(trim(t0.rvmp_username), ''), 'RVMP:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rvmp_username as PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif('RVMP:' || nullif(trim(t0.rvmp_username), ''), 'RVMP:'), '')) is not null

    union all

    -- branch 27: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): QUOTE_COMPARISON.Option Code=RVMP_PRICE
    select
        null, null, null, null, null, null, null, null, null,
        nullif(nullif(trim(t0.quote_ref_no), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RVMP_PRICE' as QUOTE_COMPARISON__OPTION_CODE_CK,
        t0.rvmp_price as QUOTE_COMPARISON__PREMIUM_OPTION,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.quote_ref_no), ''), '')) is not null

    union all

    -- branch 28: BJAZ_MOT_WINBACK_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.partner_id)), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), '') as FINANCIAL_TRANSACTION_BK,
        null,
        nullif(nullif(trim(to_char(t0.location_code)), ''), '') as ORG_UNIT_BK,
        null,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null,
        nullif(nullif(trim(t0.registration_no), ''), '') as RISK_OBJECT_BK,
        null, null,
        1 as __LNK_CHANNEL_ORG_UNIT,
        1 as __LNK_FINTXN_POLICY,
        null,
        1 as __LNK_POLICY_CHANNEL,
        null,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_PRODUCT,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.pa_dft_flag as AUG_RISK_MOTOR_CPA__COMPULSORY_PA_DEFAULT_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payment_mode as FINTXN_PREMIUM__COLLECTION_MODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (coalesce(nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), ''), nullif(nullif(trim(t0.bjazpolicyno), ''), ''), nullif(nullif(trim(t0.registration_no), ''), ''), nullif(nullif(trim(to_char(t0.location_code)), ''), ''), nullif(nullif(trim(to_char(t0.partner_id)), ''), ''), nullif(nullif(trim(to_char(t0.product_code)), ''), ''), nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), ''))) is not null

    union all

    -- branch 29: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(to_char(t0.call_id)), ''), '') as CASE_BK,
        nullif(nullif(trim(to_char(t0.part_id)), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(t0.receipt_no), ''), '') as FINANCIAL_TRANSACTION_BK,
        null,
        nullif(nullif(trim(to_char(t0.company_org_unit)), ''), '') as ORG_UNIT_BK,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), '') as PRODUCT_BK,
        null,
        nullif(nullif(trim(t0.quote_ref_no), ''), '') as QUOTE_BK,
        nullif(md5(normalise(upper(nullif(trim(t0.student_name), '')))), '') as RISK_OBJECT_BK,
        null,
        1 as __LNK_CASE_POLICY,
        null,
        1 as __LNK_FINTXN_POLICY,
        null, null, null,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PRODUCT,
        null, null, null, null,
        1 as __LNK_QUOTE_PRODUCT,
        null, null, null,
        t0.bafl_request_id as AUG_CHANNEL_DIGITAL_INTEGRATION__PARTNER_REQUEST_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.data_source as AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK,
        t0.browser as AUG_PARTY_DIGITAL_IDENTITY__BROWSER_NAME,
        t0.machine_ip as AUG_PARTY_DIGITAL_IDENTITY__CLIENT_IP_ADDRESS,
        t0.bandwidth as AUG_PARTY_DIGITAL_IDENTITY__CONNECTION_BANDWIDTH,
        t0.third_ip as AUG_PARTY_DIGITAL_IDENTITY__FORWARDED_IP_ADDRESS,
        null,
        t0.proxy_ip as AUG_PARTY_DIGITAL_IDENTITY__PROXY_IP_ADDRESS,
        null, null, null, null,
        t0.no_of_vehicle_4w as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FOUR_WHEELER_OWNED_COUNT,
        t0.no_of_vehicle_2w as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__TWO_WHEELER_OWNED_COUNT,
        null,
        t0.call_id as AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE_CK,
        t0.details_pikup_time as AUG_PARTY_INTERACTION_EVENT__FOLLOW_UP_TIME,
        null,
        t0.ivrs_time as AUG_PARTY_INTERACTION_EVENT__INTERACTION_TIME,
        t0.avail_disc_by_telling_abt_u as AUG_PARTY_MARKETING__PROFILING_DISCLOSURE_OPTED_INDICATOR,
        t0.promotion_no as AUG_PARTY_MARKETING__PROMOTION_NUMBER,
        t0.url as AUG_PARTY_ONBOARDING_JOURNEY__JOURNEY_PAGE_URL,
        null, null, null, null, null, null,
        t0.main_agent_code as AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        t0.service_charge_rate as AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE,
        t0.copayment_yn as AUG_POLICY_TERMS__CO_PAYMENT_APPLICABLE_INDICATOR,
        null,
        t0.geog_extn_code as AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE,
        null, null, null,
        t0.student_remarks as AUG_RISK_PERSON_STUDENT_PA__STUDENT_REMARKS,
        t0.callme as COMMON_COMMUNICATION_PREFERENCE__CALL_OPT_IN_INDICATOR,
        null, null, null, null, null, null, null, null,
        t0.payment_mode as FINTXN_PREMIUM__COLLECTION_MODE,
        t0.payment_received_yn as FINTXN_PREMIUM__COLLECTION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.details_pikup_date as PARTY_INTERACTION_EVENT__FOLLOW_UP_DATE,
        t0.ivrs_date as PARTY_INTERACTION_EVENT__INTERACTION_DATE,
        null, null, null, null, null, null, null,
        t0.course_duration as RISK_PERSON_STUDENT_PA__COURSE_DURATION_MONTHS,
        t0.course as RISK_PERSON_STUDENT_PA__COURSE_NAME,
        t0.school_address as RISK_PERSON_STUDENT_PA__INSTITUTION_ADDRESS,
        t0.school_name as RISK_PERSON_STUDENT_PA__INSTITUTION_NAME,
        t0.semester_no as RISK_PERSON_STUDENT_PA__SEMESTER_NUMBER,
        t0.student_fitness as RISK_PERSON_STUDENT_PA__STUDENT_FITNESS_STATUS,
        t0.tution_fee as RISK_PERSON_STUDENT_PA__TUITION_FEE_AMOUNT,
        t0.tutionfee_by as RISK_PERSON_STUDENT_PA__TUITION_FEE_PAYER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), ''), nullif(md5(normalise(upper(nullif(trim(t0.student_name), '')))), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(t0.quote_ref_no), ''), ''), nullif(nullif(trim(t0.receipt_no), ''), ''), nullif(nullif(trim(to_char(t0.call_id)), ''), ''), nullif(nullif(trim(to_char(t0.company_org_unit)), ''), ''), nullif(nullif(trim(to_char(t0.part_id)), ''), ''), nullif(nullif(trim(to_char(t0.product_4digit_code)), ''), ''))) is not null

    union all

    -- branch 30: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_COMMON_CONTACT.Contact Point Type=ALTERNATE_LANDLINE, AUG_COMMON_CONTACT.Contact Priority Order=2
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ALTERNATE_LANDLINE' as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        t0.telephone2 as AUG_COMMON_CONTACT__ALTERNATE_LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 31: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_COMMON_CONTACT.Contact Point Type=PREFERENCE
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PREFERENCE' as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null,
        t0.prefereddate as AUG_COMMON_CONTACT__PREFERRED_CONTACT_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 32: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=PRODUCT
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PRODUCT' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.product_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 33: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=PREMIUM
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PREMIUM' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.premium_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 34: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=CUSTOMER
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'CUSTOMER' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.customer_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 35: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=PAYMENT
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'PAYMENT' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.payment_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 36: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=POLICY
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'POLICY' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.policy_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 37: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): AUG_PARTY_DIGITAL_JOURNEY_STAGE.Journey Stage=CONTACT
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'CONTACT' as AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
        t0.contact_page as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 38: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): LEAD_ATTRIBUTION.Attribution Parameter=QUALITY_EXT_ID
    select
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'QUALITY_EXT_ID' as LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
        t0.quality_ext_id as LEAD_ATTRIBUTION__LEAD_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 39: BJAZ_MOT_WS_POL_DTLS
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null,
        nullif(nullif(trim(t0.quote_ref_no), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null, null, null, null,
        1 as __LNK_QUOTE_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(t0.quote_ref_no), ''), ''))) is not null

    union all

    -- branch 40: BJAZ_WAP_MOT_ADDONPKG
    select
        null, null,
        nullif(nullif(trim(to_char(t0.trans_id)), ''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.motorws_trans_id as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_addonpkg') }} t0
    where (nullif(nullif(trim(to_char(t0.trans_id)), ''), '')) is not null

    union all

    -- branch 41: BJAZ_WAP_MOT_STP_RATE_SUMM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.transaction_id)), ''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.motor_ws_trans_id as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_stp_rate_summ') }} t0
    where (nullif(nullif(trim(to_char(t0.transaction_id)), ''), '')) is not null

)

select
    CASE_BK,
    DISTRIBUTION_CHANNEL_BK,
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    QUOTE_BK,
    RISK_OBJECT_BK,
    ROLE_TYPE_CODE,
    __LNK_CASE_POLICY,
    __LNK_CHANNEL_ORG_UNIT,
    __LNK_FINTXN_POLICY,
    __LNK_PARTY_LOCATION,
    __LNK_POLICY_CHANNEL,
    __LNK_POLICY_LOCATION,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_PROPOSAL_POLICY,
    __LNK_PROPOSAL_PRODUCT,
    __LNK_PROPOSAL_RISK_OBJECT,
    __LNK_QUOTE_PRODUCT,
    __LNK_QUOTE_PROPOSAL,
    __LNK_QUOTE_RISK_OBJECT,
    __LNK_RISK_OBJECT_LOCATION,
    first_value(AUG_CHANNEL_DIGITAL_INTEGRATION__PARTNER_REQUEST_REFERENCE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_DIGITAL_INTEGRATION__PARTNER_REQUEST_REFERENCE,
    AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
    AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
    first_value(AUG_COMMON_CONTACT__ALTERNATE_LANDLINE_NUMBER) ignore nulls over (partition by PARTY_BK, AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK, AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CONTACT__ALTERNATE_LANDLINE_NUMBER,
    first_value(AUG_COMMON_CONTACT__PREFERRED_CONTACT_DATE) ignore nulls over (partition by PARTY_BK, AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK, AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CONTACT__PREFERRED_CONTACT_DATE,
    first_value(AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_DATE,
    first_value(AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_NUMBER,
    first_value(AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CHANNEL_AUTHORISATION__AUTHORISATION_PIN_STATUS,
    first_value(AUG_FINTXN_HEADER__CHANNEL_REQUEST_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_HEADER__CHANNEL_REQUEST_REFERENCE,
    first_value(AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT,
    first_value(AUG_FINTXN_PREMIUM__FINAL_PREMIUM) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__FINAL_PREMIUM,
    first_value(AUG_FINTXN_PREMIUM__IMT_ENDORSEMENT_CODE_LIST) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__IMT_ENDORSEMENT_CODE_LIST,
    first_value(AUG_FINTXN_PREMIUM__NET_PREMIUM_COMPONENT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__NET_PREMIUM_COMPONENT,
    first_value(AUG_FINTXN_PREMIUM__NO_CLAIM_BONUS_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__NO_CLAIM_BONUS_AMOUNT,
    first_value(AUG_FINTXN_PREMIUM__TOTAL_ACT_LIABILITY_PREMIUM) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__TOTAL_ACT_LIABILITY_PREMIUM,
    first_value(AUG_FINTXN_PREMIUM__TOTAL_IEV_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__TOTAL_IEV_AMOUNT,
    first_value(AUG_FINTXN_PREMIUM__TOTAL_OWN_DAMAGE_PREMIUM) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__TOTAL_OWN_DAMAGE_PREMIUM,
    AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
    first_value(AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR) ignore nulls over (partition by LOCATION_BK, PARTY_BK, AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
    AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
    AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__BROWSER_NAME) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__BROWSER_NAME,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__CLIENT_IP_ADDRESS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__CLIENT_IP_ADDRESS,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__CONNECTION_BANDWIDTH) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__CONNECTION_BANDWIDTH,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__FORWARDED_IP_ADDRESS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__FORWARDED_IP_ADDRESS,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__MACHINE_IP_ADDRESS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__MACHINE_IP_ADDRESS,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__PROXY_IP_ADDRESS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__PROXY_IP_ADDRESS,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__THIRD_IP_ADDRESS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK, AUG_PARTY_DIGITAL_IDENTITY__ACCESS_CHANNEL_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__THIRD_IP_ADDRESS,
    AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CODE_CK,
    AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK,
    first_value(AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CODE_CK, AUG_PARTY_DIGITAL_JOURNEY_STAGE__JOURNEY_STAGE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FOUR_WHEELER_OWNED_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FOUR_WHEELER_OWNED_COUNT,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__TWO_WHEELER_OWNED_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__TWO_WHEELER_OWNED_COUNT,
    AUG_PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK,
    AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE_CK,
    first_value(AUG_PARTY_INTERACTION_EVENT__FOLLOW_UP_TIME) ignore nulls over (partition by PARTY_BK, AUG_PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK, AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INTERACTION_EVENT__FOLLOW_UP_TIME,
    first_value(AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK, AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE,
    first_value(AUG_PARTY_INTERACTION_EVENT__INTERACTION_TIME) ignore nulls over (partition by PARTY_BK, AUG_PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK, AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INTERACTION_EVENT__INTERACTION_TIME,
    first_value(AUG_PARTY_MARKETING__PROFILING_DISCLOSURE_OPTED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_MARKETING__PROFILING_DISCLOSURE_OPTED_INDICATOR,
    first_value(AUG_PARTY_MARKETING__PROMOTION_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_MARKETING__PROMOTION_NUMBER,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__JOURNEY_PAGE_URL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__JOURNEY_PAGE_URL,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__CALLBACK_REQUESTED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__CALLBACK_REQUESTED_INDICATOR,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_DATE,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_TIME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_TIME,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_CONTACT_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_CONTACT_DATE,
    first_value(AUG_PARTY_VEHICLE_OWNER__FOUR_WHEELER_OWNED_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_VEHICLE_OWNER__FOUR_WHEELER_OWNED_COUNT,
    first_value(AUG_PARTY_VEHICLE_OWNER__TWO_WHEELER_OWNED_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_VEHICLE_OWNER__TWO_WHEELER_OWNED_COUNT,
    AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
    first_value(AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE,
    first_value(AUG_POLICY_TERMS__CO_PAYMENT_APPLICABLE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__CO_PAYMENT_APPLICABLE_INDICATOR,
    first_value(AUG_POLICY_TERMS__CO_PAYMENT_OPTED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__CO_PAYMENT_OPTED_INDICATOR,
    first_value(AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE,
    first_value(AUG_RISK_MOTOR_CPA__COMPULSORY_PA_DEFAULT_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_CPA__COMPULSORY_PA_DEFAULT_INDICATOR,
    first_value(AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_CONTACT_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_CONTACT_NUMBER,
    first_value(AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_NAME,
    first_value(AUG_RISK_PERSON_STUDENT_PA__STUDENT_REMARKS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_PERSON_STUDENT_PA__STUDENT_REMARKS,
    first_value(COMMON_COMMUNICATION_PREFERENCE__CALL_OPT_IN_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_COMMUNICATION_PREFERENCE__CALL_OPT_IN_INDICATOR,
    first_value(FINTXN_HEADER__NARRATION) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__NARRATION,
    first_value(FINTXN_HEADER__ORG_UNIT_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__ORG_UNIT_CODE,
    first_value(FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__ORIGINATING_SYSTEM_REFERENCE,
    first_value(FINTXN_HEADER__SOURCE_REFERENCE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
    first_value(FINTXN_HEADER__TRANSACTION_CHANNEL) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_CHANNEL,
    first_value(FINTXN_HEADER__TRANSACTION_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_DATE,
    first_value(FINTXN_HEADER__TRANSACTION_SUB_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
    first_value(FINTXN_HEADER__TRANSACTION_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_TYPE,
    first_value(FINTXN_PREMIUM__COLLECTION_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__COLLECTION_MODE,
    first_value(FINTXN_PREMIUM__COLLECTION_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__COLLECTION_STATUS,
    first_value(FINTXN_PREMIUM__DISCOUNT_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__DISCOUNT_AMOUNT,
    first_value(FINTXN_PREMIUM__GROSS_PREMIUM) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__GROSS_PREMIUM,
    first_value(FINTXN_PREMIUM__LOADING_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__LOADING_AMOUNT,
    first_value(FINTXN_PREMIUM__NET_PREMIUM) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__NET_PREMIUM,
    first_value(FINTXN_PREMIUM__STAMP_DUTY_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__STAMP_DUTY_AMOUNT,
    FINTXN_TAX__TAX_TYPE_CK,
    first_value(FINTXN_TAX__SERVICE_TAX_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__SERVICE_TAX_AMOUNT,
    FIN_CHARGE_RATE__CHARGE_TYPE_CK,
    first_value(FIN_CHARGE_RATE__CHARGE_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FIN_CHARGE_RATE__CHARGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_CHARGE_RATE__CHARGE_RATE,
    LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK,
    first_value(LEAD_ATTRIBUTION__LEAD_REFERENCE) ignore nulls over (partition by PARTY_BK, LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LEAD_ATTRIBUTION__LEAD_REFERENCE,
    first_value(LEAD_ATTRIBUTION__PARAMETER_VALUE) ignore nulls over (partition by PARTY_BK, LEAD_ATTRIBUTION__ATTRIBUTION_PARAMETER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LEAD_ATTRIBUTION__PARAMETER_VALUE,
    LNK_ROLE_AGENT__ROLE_TYPE_CK,
    first_value(LNK_ROLE_AGENT__AGENT_CODE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__AGENT_CODE,
    LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
    first_value(LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
    LNK_ROLE_POSP__ROLE_TYPE_CK,
    first_value(LNK_ROLE_POSP__POSP_CODE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_POSP__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_POSP__POSP_CODE,
    PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
    first_value(PARTY_BANKING__BANK_NAME) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__BANK_NAME,
    PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK,
    first_value(PARTY_CORRESPONDENCE__TEMPLATE_REFERENCE) ignore nulls over (partition by PARTY_BK, PARTY_CORRESPONDENCE__DISPATCH_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CORRESPONDENCE__TEMPLATE_REFERENCE,
    PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER) ignore nulls over (partition by PARTY_BK, PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER,
    first_value(PARTY_EMPLOYMENT__INDUSTRY_SECTOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__INDUSTRY_SECTOR,
    first_value(PARTY_FINANCIAL_PROFILE__CIBIL_SCORE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FINANCIAL_PROFILE__CIBIL_SCORE,
    first_value(PARTY_FINANCIAL_PROFILE__CREDIT_SCORE_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FINANCIAL_PROFILE__CREDIT_SCORE_DATE,
    PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK,
    first_value(PARTY_INTERACTION_EVENT__FOLLOW_UP_DATE) ignore nulls over (partition by PARTY_BK, PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INTERACTION_EVENT__FOLLOW_UP_DATE,
    first_value(PARTY_INTERACTION_EVENT__INTERACTION_DATE) ignore nulls over (partition by PARTY_BK, PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INTERACTION_EVENT__INTERACTION_DATE,
    POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(POLICY_DOC_CHECKLIST__VERIFICATION_STATUS) ignore nulls over (partition by POLICY_BK, POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DOC_CHECKLIST__VERIFICATION_STATUS,
    first_value(POLICY_LIFECYCLE__ASSIGNEE_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_LIFECYCLE__ASSIGNEE_REFERENCE,
    first_value(PROPOSAL_UNDERWRITING__REFERRAL_DATE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_UNDERWRITING__REFERRAL_DATE,
    first_value(PROPOSAL_UNDERWRITING__REFERRAL_REASON) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_UNDERWRITING__REFERRAL_REASON,
    QUOTE_COMPARISON__OPTION_CODE_CK,
    first_value(QUOTE_COMPARISON__PREMIUM_OPTION) ignore nulls over (partition by QUOTE_BK, QUOTE_COMPARISON__OPTION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_COMPARISON__PREMIUM_OPTION,
    first_value(RISK_PERSON_STUDENT_PA__COURSE_DURATION_MONTHS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_STUDENT_PA__COURSE_DURATION_MONTHS,
    first_value(RISK_PERSON_STUDENT_PA__COURSE_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_STUDENT_PA__COURSE_NAME,
    first_value(RISK_PERSON_STUDENT_PA__INSTITUTION_ADDRESS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_STUDENT_PA__INSTITUTION_ADDRESS,
    first_value(RISK_PERSON_STUDENT_PA__INSTITUTION_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_STUDENT_PA__INSTITUTION_NAME,
    first_value(RISK_PERSON_STUDENT_PA__SEMESTER_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_STUDENT_PA__SEMESTER_NUMBER,
    first_value(RISK_PERSON_STUDENT_PA__STUDENT_FITNESS_STATUS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_STUDENT_PA__STUDENT_FITNESS_STATUS,
    first_value(RISK_PERSON_STUDENT_PA__TUITION_FEE_AMOUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_STUDENT_PA__TUITION_FEE_AMOUNT,
    first_value(RISK_PERSON_STUDENT_PA__TUITION_FEE_PAYER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_STUDENT_PA__TUITION_FEE_PAYER,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on PARTY_BK (SAT_AUG_COMMON_CONTACT, SAT_AUG_PARTY_DIGITAL_IDENTITY, SAT_AUG_PARTY_DIGITAL_JOURNEY_STAGE, SAT_AUG_PARTY_INTERACTION_EVENT, SAT_LEAD_ATTRIBUTION, SAT_LNK_ROLE_AGENT, SAT_LNK_ROLE_EMPLOYEE, SAT_LNK_ROLE_POSP, SAT_PARTY_BANKING, SAT_PARTY_CORRESPONDENCE, SAT_PARTY_DIGITAL_IDENTITY, SAT_PARTY_INTERACTION_EVENT):
    -- one load time per PARTY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_COMMON_CONTACT__ALTERNATE_LANDLINE_NUMBER, m.AUG_COMMON_CONTACT__PREFERRED_CONTACT_DATE, m.AUG_PARTY_DIGITAL_IDENTITY__BROWSER_NAME, m.AUG_PARTY_DIGITAL_IDENTITY__CLIENT_IP_ADDRESS, m.AUG_PARTY_DIGITAL_IDENTITY__CONNECTION_BANDWIDTH, m.AUG_PARTY_DIGITAL_IDENTITY__FORWARDED_IP_ADDRESS, m.AUG_PARTY_DIGITAL_IDENTITY__MACHINE_IP_ADDRESS, m.AUG_PARTY_DIGITAL_IDENTITY__PROXY_IP_ADDRESS, m.AUG_PARTY_DIGITAL_IDENTITY__THIRD_IP_ADDRESS, m.AUG_PARTY_DIGITAL_JOURNEY_STAGE__STAGE_REACHED_INDICATOR, m.AUG_PARTY_INTERACTION_EVENT__FOLLOW_UP_TIME, m.AUG_PARTY_INTERACTION_EVENT__INTERACTION_REFERENCE, m.AUG_PARTY_INTERACTION_EVENT__INTERACTION_TIME, m.LEAD_ATTRIBUTION__LEAD_REFERENCE, m.LEAD_ATTRIBUTION__PARAMETER_VALUE, m.LNK_ROLE_AGENT__AGENT_CODE, m.LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE, m.LNK_ROLE_POSP__POSP_CODE, m.PARTY_BANKING__BANK_NAME, m.PARTY_CORRESPONDENCE__TEMPLATE_REFERENCE, m.PARTY_DIGITAL_IDENTITY__LOGIN_IDENTIFIER, m.PARTY_INTERACTION_EVENT__FOLLOW_UP_DATE, m.PARTY_INTERACTION_EVENT__INTERACTION_DATE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on LOCATION_BK (SAT_AUG_PARTY_CONTACT_ADDRESS_LINK):
    -- one load time per LOCATION_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when m.AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.LOCATION_BK) as LOCATION_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on POLICY_BK (SAT_AUG_POLICY_INTERMEDIARY_SPLIT, SAT_POLICY_DOC_CHECKLIST):
    -- one load time per POLICY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_RATE, m.POLICY_DOC_CHECKLIST__VERIFICATION_STATUS) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on FINANCIAL_TRANSACTION_BK (SAT_FINTXN_TAX, SAT_FIN_CHARGE_RATE):
    -- one load time per FINANCIAL_TRANSACTION_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.FINTXN_TAX__SERVICE_TAX_AMOUNT, m.FIN_CHARGE_RATE__CHARGE_RATE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.FINANCIAL_TRANSACTION_BK) as FINANCIAL_TRANSACTION_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on QUOTE_BK (SAT_QUOTE_COMPARISON):
    -- one load time per QUOTE_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when m.QUOTE_COMPARISON__PREMIUM_OPTION is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.QUOTE_BK) as QUOTE_BK__MA_LOAD_DATETIME
from merged m
