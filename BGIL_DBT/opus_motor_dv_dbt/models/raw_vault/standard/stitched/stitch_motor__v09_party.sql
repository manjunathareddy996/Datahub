-- CENTRAL VIEW v09_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BA_QUOTE_MOT_DTLS
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_CLM_MOTOR_INTIM_DETAILS
--   BJAZ_CLM_SUBFILE_MOT_EXT
--   BJAZ_CVTP_WS_DATA
--   BJAZ_CVTP_WS_DATA_EXTN
--   BJAZ_IIB_INSURER_MASTER
--   BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
--   BJAZ_MOTORTHEFT_CASE_DTLS
--   BJAZ_MOT_ADD_QSTN_DTLS
--   BJAZ_MOT_NAMED_DRIVER_EXTN
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS_EXTN
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_UW_BUDGET_MST
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_RTA_STATE_MASTER
--   BJAZ_SCR_MOT_VEH_DTLS
--   BJAZ_WAP_MOTOR_IW_ASSIST
--   BJAZ_WAP_MOT_ADD_QSTN_DTLS
--   BJAZ_WS_MOTCLM_DETAILS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_HEADER
--   SAT_AUG_CASE_SERVICE_REQUEST
--   SAT_AUG_CHANNEL_SALES_TARGET
--   SAT_AUG_PARTY_ORGANISATION_PROFILE
--   SAT_AUG_PROPOSAL_UNDERWRITING
--   SAT_CASE_SERVICE_REQUEST
--   SAT_CHANNEL_SALES_TARGET
--   SAT_COMMON_CONTACT
--   SAT_PARTY_IDENTITY
--   SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_PROPOSAL_DECLARATIONS
--   SAT_RISK_MOTOR_DRIVER
--   SAT_RISK_OBJECT_OWNERSHIP_HISTORY
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_QUOTE_MOT_DTLS
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as CASE_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        nullif(md5(normalise(upper(nullif(coalesce(t0.nominee_name, ''), '')))), '') as PARTY_BK,
        cast(null as varchar) as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), '') as RISK_OBJECT_BK,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as AUG_CASE_SERVICE_REQUEST__ASSISTANCE_OFFER_PUSHED_INDICATOR,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__BORROWED_AMOUNT_BRANCH_OFFICE,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__BORROWED_AMOUNT_ZONAL_HEAD,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__BUDGETED_OWN_DAMAGE_PREMIUM,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__BUDGET_AMOUNT_BRANCH_OFFICE,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__BUDGET_AMOUNT_ZONAL_HEAD,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__BUDGET_REFERENCE,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__CARRIED_FORWARD_AMOUNT_BRANCH_OFFICE,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__CARRIED_FORWARD_AMOUNT_ZONAL_HEAD,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__PORTFOLIO_GROUP_CODE,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__RENEWAL_TYPE,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__TARGET_YEAR,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__UTILISED_AMOUNT_BRANCH_OFFICE,
        cast(null as varchar) as AUG_CHANNEL_SALES_TARGET__UTILISED_AMOUNT_ZONAL_HEAD,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__INTERNAL_INSURER_CODE,
        cast(null as varchar) as AUG_PROPOSAL_UNDERWRITING__DRIVING_OFFENCE_SCORE,
        cast(null as varchar) as AUG_PROPOSAL_UNDERWRITING__MANUAL_APPROVAL_INDICATOR,
        cast(null as varchar) as AUG_PROPOSAL_UNDERWRITING__PARTIAL_LOSS_PROPENSITY_SCORE,
        cast(null as varchar) as AUG_PROPOSAL_UNDERWRITING__PINCODE_ELIGIBILITY_CONDITION,
        cast(null as varchar) as AUG_PROPOSAL_UNDERWRITING__REFERRED_BY_REFERENCE,
        cast(null as varchar) as CASE_SERVICE_REQUEST__SERVICE_REQUEST_TYPE,
        cast(null as varchar) as CHANNEL_SALES_TARGET__TARGET_PERIOD_CK,
        cast(null as varchar) as CHANNEL_SALES_TARGET__TARGET_TYPE_CK,
        cast(null as varchar) as CHANNEL_SALES_TARGET__BUDGET_AMOUNT,
        cast(null as varchar) as CHANNEL_SALES_TARGET__BUDGET_PERCENTAGE,
        cast(null as varchar) as CHANNEL_SALES_TARGET__TARGET_PERIOD,
        cast(null as varchar) as CHANNEL_SALES_TARGET__TARGET_TYPE,
        cast(null as varchar) as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        cast(null as varchar) as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        cast(null as varchar) as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        cast(null as varchar) as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__EMAIL_ADDRESS,
        cast(null as varchar) as COMMON_CONTACT__LANDLINE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__MOBILE_NUMBER,
        cast(null as varchar) as COMMON_CONTACT__PREFERRED_CONTACT_TIME,
        cast(null as varchar) as COMMON_CONTACT__WHATSAPP_OPT_IN_INDICATOR,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__NAME_SUFFIX,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        t0.nominee_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__SALUTATION,
        cast(null as varchar) as PARTY_IDENTITY__TITLE_CODE,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_INCOME,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__HOUSE_OWNERSHIP_TYPE,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__INDUSTRY_OF_EMPLOYMENT,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_CHILDREN,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR,
        cast(null as varchar) as PROPOSAL_DECLARATIONS__PREVIOUS_CLAIM_INDICATOR,
        t0.owner_dl_number as RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK,
        cast(null as varchar) as RISK_MOTOR_DRIVER__DRIVER_NAME,
        cast(null as varchar) as RISK_MOTOR_DRIVER__DRIVER_RELATIONSHIP,
        t0.owner_dl_number as RISK_MOTOR_DRIVER__DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as RISK_MOTOR_DRIVER__LICENCE_TYPE,
        cast(null as varchar) as RISK_MOTOR_DRIVER__OWNER_DRIVER_INDICATOR,
        cast(null as varchar) as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        cast(null as varchar) as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.vehicle_reg_no), '')), ''), nullif(md5(normalise(upper(nullif(coalesce(t0.nominee_name, ''), '')))), ''))) is not null

    union all

    -- branch 1: BJAZ_AGENCY_MOT_WAR_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.your_name, '') || '|' || coalesce(to_char(t0.mob_no), ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.mob_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.your_name, '') || '|' || coalesce(to_char(t0.mob_no), ''), '|')))), '')) is not null

    union all

    -- branch 2: BJAZ_AGENCY_MOT_WAR_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.your_name, '') || '|' || coalesce(to_char(t0.mob_no), ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.your_name, '') || '|' || coalesce(to_char(t0.mob_no), ''), '|')))), '')) is not null

    union all

    -- branch 3: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.your_name, '') || '|' || coalesce(to_char(t0.mob_no), ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.your_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null,
        t0.title as PARTY_IDENTITY__SALUTATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.your_name, '') || '|' || coalesce(to_char(t0.mob_no), ''), '|')))), '')) is not null

    union all

    -- branch 4: BJAZ_CLM_MOTOR_INTIM_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.cp_name, '') || '|' || coalesce(t0.cp_mobile, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.cp_tel as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.cp_name, '') || '|' || coalesce(t0.cp_mobile, ''), '|')))), '')) is not null

    union all

    -- branch 5: BJAZ_CLM_MOTOR_INTIM_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.cp_name, '') || '|' || coalesce(t0.cp_mobile, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.cp_mobile as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.cp_name, '') || '|' || coalesce(t0.cp_mobile, ''), '|')))), '')) is not null

    union all

    -- branch 6: BJAZ_CLM_MOTOR_INTIM_DETAILS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.cp_name, '') || '|' || coalesce(t0.cp_mobile, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.cp_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.cp_name, '') || '|' || coalesce(t0.cp_mobile, ''), '|')))), '')) is not null

    union all

    -- branch 7: BJAZ_CLM_MOTOR_INTIM_DETAILS
    select
        null, null, null,
        nullif(nullif('PAN:' || nullif(trim(t0.insured_panno), ''), 'PAN:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.insured_dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (nullif(nullif('PAN:' || nullif(trim(t0.insured_panno), ''), 'PAN:'), '')) is not null

    union all

    -- branch 8: BJAZ_CLM_SUBFILE_MOT_EXT
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.investigator_name, ''), '')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.investigator_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_subfile_mot_ext') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.investigator_name, ''), '')))), '')) is not null

    union all

    -- branch 9: BJAZ_CVTP_WS_DATA
    select
        null, null, null,
        nullif(nullif(trim(t0.proposerpan), ''), '') as PARTY_BK,
        nullif(nullif(trim(t0.insproposalno), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.isproposalmanualapproved as AUG_PROPOSAL_UNDERWRITING__MANUAL_APPROVAL_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.dateofbirth as PARTY_IDENTITY__DATE_OF_BIRTH,
        t0.firstname as PARTY_IDENTITY__FIRST_NAME,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        t0.lastname as PARTY_IDENTITY__LAST_NAME,
        t0.middlename as PARTY_IDENTITY__MIDDLE_NAME,
        null, null, null,
        t0.companyname as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null,
        t0.proposertype as PARTY_IDENTITY__PARTY_TYPE_CODE,
        t0.salutation as PARTY_IDENTITY__SALUTATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (coalesce(nullif(nullif(trim(t0.insproposalno), ''), ''), nullif(nullif(trim(t0.proposerpan), ''), ''))) is not null

    union all

    -- branch 10: BJAZ_CVTP_WS_DATA | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(nullif(trim(t0.proposerpan), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.email as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.proposerpan), ''), '')) is not null

    union all

    -- branch 11: BJAZ_CVTP_WS_DATA
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.bjazpolicyno, '') || '|' || coalesce(t0.paowndrivernomname, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.paowndrivernomage as PARTY_IDENTITY__AGE,
        null, null,
        t0.paowndrivernomgender as PARTY_IDENTITY__GENDER_CODE,
        null, null, null, null,
        t0.paowndrivernomname as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.bjazpolicyno, '') || '|' || coalesce(t0.paowndrivernomname, ''), '|')))), '')) is not null

    union all

    -- branch 12: BJAZ_CVTP_WS_DATA_EXTN
    select
        null, null, null,
        nullif(nullif('POSP:' || nullif(trim(t0.pspuniqueno), ''), 'POSP:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.pspname as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data_extn') }} t0
    where (nullif(nullif('POSP:' || nullif(trim(t0.pspuniqueno), ''), 'POSP:'), '')) is not null

    union all

    -- branch 13: BJAZ_IIB_INSURER_MASTER
    select
        null, null, null,
        nullif(nullif('INSURER:' || nullif(trim(t0.insurer_code), ''), 'INSURER:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bjazinsurercode as AUG_PARTY_ORGANISATION_PROFILE__INTERNAL_INSURER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.insurer_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_iib_insurer_master') }} t0
    where (nullif(nullif('INSURER:' || nullif(trim(t0.insurer_code), ''), 'INSURER:'), '')) is not null

    union all

    -- branch 14: BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.txt_insurer, ''), '')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.txt_insurer as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_iib_sudars_policy_dtl_hst_qm') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.txt_insurer, ''), '')))), '')) is not null

    union all

    -- branch 15: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.adv_name, '') || '|' || coalesce(t0.adv_email, '') || '|' || coalesce(t0.adv_contact, ''), '||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.adv_contact as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.adv_name, '') || '|' || coalesce(t0.adv_email, '') || '|' || coalesce(t0.adv_contact, ''), '||')))), '')) is not null

    union all

    -- branch 16: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.adv_name, '') || '|' || coalesce(t0.adv_email, '') || '|' || coalesce(t0.adv_contact, ''), '||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.adv_email as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.adv_name, '') || '|' || coalesce(t0.adv_email, '') || '|' || coalesce(t0.adv_contact, ''), '||')))), '')) is not null

    union all

    -- branch 17: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.court_name, '') || '|' || coalesce(t0.court_location, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.court_email as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.court_name, '') || '|' || coalesce(t0.court_location, ''), '|')))), '')) is not null

    union all

    -- branch 18: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.highest_bidder_name, '') || '|' || coalesce(t0.highest_bidder_address, '') || '|' || coalesce(t0.highest_bidder_contact_no, ''), '||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.highest_bidder_contact_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.highest_bidder_name, '') || '|' || coalesce(t0.highest_bidder_address, '') || '|' || coalesce(t0.highest_bidder_contact_no, ''), '||')))), '')) is not null

    union all

    -- branch 19: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.buyer_name, '') || '|' || coalesce(t0.buyer_address, '') || '|' || coalesce(t0.contact_no, ''), '||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.contact_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.buyer_name, '') || '|' || coalesce(t0.buyer_address, '') || '|' || coalesce(t0.contact_no, ''), '||')))), '')) is not null

    union all

    -- branch 20: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.adv_name, '') || '|' || coalesce(t0.adv_email, '') || '|' || coalesce(t0.adv_contact, ''), '||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.adv_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.adv_name, '') || '|' || coalesce(t0.adv_email, '') || '|' || coalesce(t0.adv_contact, ''), '||')))), '')) is not null

    union all

    -- branch 21: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.bid_court_name, '') || '|' || coalesce(t0.bid_court_location, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.bid_court_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.bid_court_name, '') || '|' || coalesce(t0.bid_court_location, ''), '|')))), '')) is not null

    union all

    -- branch 22: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.buyer_name, '') || '|' || coalesce(t0.buyer_address, '') || '|' || coalesce(t0.contact_no, ''), '||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.buyer_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null,
        t0.category as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
        t0.cust_type as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.buyer_name, '') || '|' || coalesce(t0.buyer_address, '') || '|' || coalesce(t0.contact_no, ''), '||')))), '')) is not null

    union all

    -- branch 23: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.original_rc_name, ''), '')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.original_rc_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.original_rc_name, ''), '')))), '')) is not null

    union all

    -- branch 24: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.investigator_name, ''), '')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.investigator_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.investigator_name, ''), '')))), '')) is not null

    union all

    -- branch 25: BJAZ_MOT_ADD_QSTN_DTLS
    select
        null, null, null,
        nullif(nullif(trim(t0.pan_no), ''), '') as PARTY_BK,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.driving_offence_score as AUG_PROPOSAL_UNDERWRITING__DRIVING_OFFENCE_SCORE,
        null,
        t0.partial_loss_score as AUG_PROPOSAL_UNDERWRITING__PARTIAL_LOSS_PROPENSITY_SCORE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.age as PARTY_IDENTITY__AGE,
        null, null,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        null,
        t0.profession as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        t0.bagic_mot_pol_yn as PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR,
        t0.claim_yn as PROPOSAL_DECLARATIONS__PREVIOUS_CLAIM_INDICATOR,
        null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_add_qstn_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.pan_no), ''), ''), nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), ''))) is not null

    union all

    -- branch 26: BJAZ_MOT_NAMED_DRIVER_EXTN
    select
        null, null, null,
        nullif(nullif('DL:' || nullif(trim(t0.driver_licence_no), ''), 'DL:'), '') as PARTY_BK,
        null,
        nullif(nullif(trim(to_char(t0.object_id)), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.age as PARTY_IDENTITY__AGE,
        null, null,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.driver_licence_no as RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK,
        t0.driver_name as RISK_MOTOR_DRIVER__DRIVER_NAME,
        t0.relationship as RISK_MOTOR_DRIVER__DRIVER_RELATIONSHIP,
        null, null,
        t0.owner_driver_flag as RISK_MOTOR_DRIVER__OWNER_DRIVER_INDICATOR,
        null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_named_driver_extn') }} t0
    where (coalesce(nullif(nullif('DL:' || nullif(trim(t0.driver_licence_no), ''), 'DL:'), ''), nullif(nullif(trim(to_char(t0.object_id)), ''), ''))) is not null

    union all

    -- branch 27: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        nullif(nullif(trim(to_char(t0.reference_id)), ''), '') as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.refer_by as AUG_PROPOSAL_UNDERWRITING__REFERRED_BY_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.age as PARTY_IDENTITY__AGE,
        t0.your_date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        t0.surname as PARTY_IDENTITY__LAST_NAME,
        t0.middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        t0.after_title as PARTY_IDENTITY__NAME_SUFFIX,
        null,
        t0.name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null,
        t0.before_title as PARTY_IDENTITY__SALUTATION,
        null,
        t0.salary as PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_INCOME,
        t0.highest_education as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        t0.home_type as PARTY_INDIVIDUAL_DEMOGRAPHICS__HOUSE_OWNERSHIP_TYPE,
        null,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        t0.no_of_children as PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_CHILDREN,
        t0.occupation as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        null, null, null, null, null, null,
        t0.license_type as RISK_MOTOR_DRIVER__LICENCE_TYPE,
        null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), ''), nullif(nullif(trim(to_char(t0.reference_id)), ''), ''))) is not null

    union all

    -- branch 28: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=ALTERNATE_EMAIL
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'ALTERNATE_EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null,
        t0.email_cust as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 29: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null,
        t0.telephone1 as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 30: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=2
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null,
        t0.telephone2 as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 31: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.mobile1 as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 32: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=ALTERNATE_MOBILE, COMMON_CONTACT.Contact Priority Order=2
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'ALTERNATE_MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null,
        t0.mobile2 as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 33: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.email as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 34: BJAZ_MOT_ONLINE_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=PREFERENCE
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'PREFERENCE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null,
        t0.preferedtime as COMMON_CONTACT__PREFERRED_CONTACT_TIME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), nullif(trim(to_char(t0.aadhaar_no)), ''), md5(normalise(upper(nullif(coalesce(t0.name, '') || '|' || coalesce(t0.mobile1, '') || '|' || coalesce(t0.email, ''), '||'))))), '')) is not null

    union all

    -- branch 35: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null, null,
        nullif(nullif('RVMP:' || nullif(trim(t0.rvmp_username), ''), 'RVMP:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rvmp_fname as PARTY_IDENTITY__FIRST_NAME,
        null,
        t0.rvmp_lname as PARTY_IDENTITY__LAST_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif('RVMP:' || nullif(trim(t0.rvmp_username), ''), 'RVMP:'), '')) is not null

    union all

    -- branch 36: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        nullif(nullif('BREAKIN:' || nullif(trim(t0.mot_pin_no), ''), 'BREAKIN:'), '') as ASSESSMENT_BK,
        null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.nom_full_name, '') || '|' || coalesce(to_char(t0.nom_dob), ''), '|')))), '') as PARTY_BK,
        null, null,
        t0.mot_pin_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nom_dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        null, null, null, null, null, null,
        t0.nom_full_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif(coalesce(t0.nom_full_name, '') || '|' || coalesce(to_char(t0.nom_dob), ''), '|')))), ''), nullif(nullif('BREAKIN:' || nullif(trim(t0.mot_pin_no), ''), 'BREAKIN:'), ''))) is not null

    union all

    -- branch 37: BJAZ_MOT_ONLINE_POL_DTLS_EXTN | child-key literal(s): COMMON_CONTACT.Contact Point Type=WHATSAPP
    select
        null, null, null,
        nullif(nullif(trim(t0.adhar_no), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'WHATSAPP' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.whatsapp_optin_flag as COMMON_CONTACT__WHATSAPP_OPT_IN_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(t0.adhar_no), ''), '')) is not null

    union all

    -- branch 38: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.ass_full_name, '') || '|' || coalesce(to_char(t0.ass_dob), ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.ass_dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        null, null, null, null, null, null,
        t0.ass_full_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.ass_full_name, '') || '|' || coalesce(to_char(t0.ass_dob), ''), '|')))), '')) is not null

    union all

    -- branch 39: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        null, null, null,
        nullif(nullif(trim(t0.adhar_no), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.completed_age as PARTY_IDENTITY__AGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.your_profession as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(t0.adhar_no), ''), '')) is not null

    union all

    -- branch 40: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.od_nom_full_name, '') || '|' || coalesce(t0.od_nom_surname, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.od_nom_surname as PARTY_IDENTITY__LAST_NAME,
        null, null, null,
        t0.od_nom_full_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.od_nom_full_name, '') || '|' || coalesce(t0.od_nom_surname, ''), '|')))), '')) is not null

    union all

    -- branch 41: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.cust_id)), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.cust_telephone as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.cust_id)), ''), '')) is not null

    union all

    -- branch 42: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.cust_id)), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.clm_mobile_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.cust_id)), ''), '')) is not null

    union all

    -- branch 43: BJAZ_MOT_RENEWAL_EXTN
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.cust_id)), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.cust_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null,
        t0.before_title as PARTY_IDENTITY__TITLE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.cust_id)), ''), '')) is not null

    union all

    -- branch 44: BJAZ_MOT_RENEWAL_EXTN
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.pa_nominee_name, '') || '|' || coalesce(t0.pa_nominee_relation, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.pa_nominee_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.pa_nominee_name, '') || '|' || coalesce(t0.pa_nominee_relation, ''), '|')))), '')) is not null

    union all

    -- branch 45: BJAZ_MOT_UW_BUDGET_MST
    select
        null, null,
        nullif(nullif(trim(t0.intermediary_id), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif('USER:' || nullif(trim(t0.user_name), ''), 'USER:'), '') as PARTY_BK,
        null, null, null, null,
        t0.for_month as AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK,
        t0.budget_type as AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK,
        t0.borrow_branch as AUG_CHANNEL_SALES_TARGET__BORROWED_AMOUNT_BRANCH_OFFICE,
        t0.borrow_zh as AUG_CHANNEL_SALES_TARGET__BORROWED_AMOUNT_ZONAL_HEAD,
        t0.total_od_prem as AUG_CHANNEL_SALES_TARGET__BUDGETED_OWN_DAMAGE_PREMIUM,
        t0.total_amnt_bo as AUG_CHANNEL_SALES_TARGET__BUDGET_AMOUNT_BRANCH_OFFICE,
        t0.total_amnt_zh as AUG_CHANNEL_SALES_TARGET__BUDGET_AMOUNT_ZONAL_HEAD,
        t0.budget_id as AUG_CHANNEL_SALES_TARGET__BUDGET_REFERENCE,
        t0.cf_branch as AUG_CHANNEL_SALES_TARGET__CARRIED_FORWARD_AMOUNT_BRANCH_OFFICE,
        t0.cf_zh as AUG_CHANNEL_SALES_TARGET__CARRIED_FORWARD_AMOUNT_ZONAL_HEAD,
        t0.group_code as AUG_CHANNEL_SALES_TARGET__PORTFOLIO_GROUP_CODE,
        t0.rnw_type as AUG_CHANNEL_SALES_TARGET__RENEWAL_TYPE,
        t0.for_year as AUG_CHANNEL_SALES_TARGET__TARGET_YEAR,
        t0.utilized_amnt_bo as AUG_CHANNEL_SALES_TARGET__UTILISED_AMOUNT_BRANCH_OFFICE,
        t0.utilized_amnt_zh as AUG_CHANNEL_SALES_TARGET__UTILISED_AMOUNT_ZONAL_HEAD,
        null, null, null, null, null, null, null,
        t0.for_month as CHANNEL_SALES_TARGET__TARGET_PERIOD_CK,
        t0.budget_type as CHANNEL_SALES_TARGET__TARGET_TYPE_CK,
        t0.total_amnt as CHANNEL_SALES_TARGET__BUDGET_AMOUNT,
        t0.budget_percentage as CHANNEL_SALES_TARGET__BUDGET_PERCENTAGE,
        t0.for_month as CHANNEL_SALES_TARGET__TARGET_PERIOD,
        t0.budget_type as CHANNEL_SALES_TARGET__TARGET_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.user_name as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_uw_budget_mst') }} t0
    where (coalesce(nullif(nullif('USER:' || nullif(trim(t0.user_name), ''), 'USER:'), ''), nullif(nullif(trim(t0.intermediary_id), ''), ''))) is not null

    union all

    -- branch 46: BJAZ_MOT_WAR_CHILD_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.mobile_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '')) is not null

    union all

    -- branch 47: BJAZ_MOT_WAR_CHILD_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.tel_no as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '')) is not null

    union all

    -- branch 48: BJAZ_MOT_WAR_CHILD_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '')) is not null

    union all

    -- branch 49: BJAZ_MOT_WAR_CHILD_DTLS
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), '') as PARTY_BK,
        null,
        nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.customer_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.ownership_no as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        t0.ownership_no as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.pan_no), ''), nullif(trim(t0.gst_no), ''), md5(normalise(upper(nullif(coalesce(t0.customer_name, '') || '|' || coalesce(to_char(t0.mobile_no), '') || '|' || coalesce(t0.email_id, ''), '||'))))), ''), nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), ''))) is not null

    union all

    -- branch 50: BJAZ_MOT_WAR_CHILD_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.sales_person_name, ''), '')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.sales_person_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.sales_person_name, ''), '')))), '')) is not null

    union all

    -- branch 51: BJAZ_MOT_WINBACK_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.last_name, '') || '|' || coalesce(t0.institution_name, '') || '|' || coalesce(t0.contact_no, '') || '|' || coalesce(t0.email_id, ''), '||||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.contact_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.last_name, '') || '|' || coalesce(t0.institution_name, '') || '|' || coalesce(t0.contact_no, '') || '|' || coalesce(t0.email_id, ''), '||||')))), '')) is not null

    union all

    -- branch 52: BJAZ_MOT_WINBACK_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.last_name, '') || '|' || coalesce(t0.institution_name, '') || '|' || coalesce(t0.contact_no, '') || '|' || coalesce(t0.email_id, ''), '||||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.email_id as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.last_name, '') || '|' || coalesce(t0.institution_name, '') || '|' || coalesce(t0.contact_no, '') || '|' || coalesce(t0.email_id, ''), '||||')))), '')) is not null

    union all

    -- branch 53: BJAZ_MOT_WINBACK_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.last_name, '') || '|' || coalesce(t0.institution_name, '') || '|' || coalesce(t0.contact_no, '') || '|' || coalesce(t0.email_id, ''), '||||')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        null,
        t0.last_name as PARTY_IDENTITY__LAST_NAME,
        null, null, null, null,
        t0.institution_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.last_name, '') || '|' || coalesce(t0.institution_name, '') || '|' || coalesce(t0.contact_no, '') || '|' || coalesce(t0.email_id, ''), '||||')))), '')) is not null

    union all

    -- branch 54: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=ALTERNATE_EMAIL
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'ALTERNATE_EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null,
        t0.email_cust as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 55: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE, COMMON_CONTACT.Contact Priority Order=1
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null,
        t0.telephone1 as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 56: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE, COMMON_CONTACT.Contact Priority Order=1
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '1' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null, null, null, null,
        t0.mobile1 as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 57: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=ALTERNATE_MOBILE, COMMON_CONTACT.Contact Priority Order=2
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'ALTERNATE_MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        '2' as COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        null,
        t0.mobile2 as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 58: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.email as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 59: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=LANDLINE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(trim(t0.family_doc), '')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'LANDLINE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null,
        t0.family_doc_tel as COMMON_CONTACT__LANDLINE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(t0.family_doc), '')))), '')) is not null

    union all

    -- branch 60: BJAZ_MOT_WS_POL_DTLS | child-key literal(s): COMMON_CONTACT.Contact Point Type=PREFERENCE
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'PREFERENCE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null, null,
        t0.preferedtime as COMMON_CONTACT__PREFERRED_CONTACT_TIME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 61: BJAZ_MOT_WS_POL_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(trim(t0.assigne_name), '')))), '') as PARTY_BK,
        null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.assigne_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.license_type as RISK_MOTOR_DRIVER__LICENCE_TYPE,
        null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(md5(normalise(upper(nullif(trim(t0.assigne_name), '')))), ''))) is not null

    union all

    -- branch 62: BJAZ_MOT_WS_POL_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(trim(t0.student_name), '')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.student_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(t0.student_name), '')))), '')) is not null

    union all

    -- branch 63: BJAZ_MOT_WS_POL_DTLS
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.age as PARTY_IDENTITY__AGE,
        t0.your_date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.your_gender as PARTY_IDENTITY__GENDER_CODE,
        t0.surname as PARTY_IDENTITY__LAST_NAME,
        t0.middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        t0.after_title as PARTY_IDENTITY__NAME_SUFFIX,
        null,
        t0.name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null,
        t0.before_title as PARTY_IDENTITY__SALUTATION,
        null,
        t0.salary as PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_INCOME,
        t0.highest_education as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        t0.home_type as PARTY_INDIVIDUAL_DEMOGRAPHICS__HOUSE_OWNERSHIP_TYPE,
        t0.prof_sector as PARTY_INDIVIDUAL_DEMOGRAPHICS__INDUSTRY_OF_EMPLOYMENT,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        t0.no_of_children as PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_CHILDREN,
        t0.occupation as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.pan_number), ''), md5(normalise(upper(nullif(coalesce(t0.first_name, '') || '|' || coalesce(t0.surname, '') || '|' || coalesce(t0.mobile1, ''), '||'))))), '')) is not null

    union all

    -- branch 64: BJAZ_MOT_WS_POL_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(trim(t0.family_doc), '')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.family_doc as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(md5(normalise(upper(nullif(trim(t0.family_doc), '')))), '')) is not null

    union all

    -- branch 65: BJAZ_RTA_STATE_MASTER
    select
        null, null, null,
        nullif(nullif('USER:' || nullif(trim(t0.user_name), ''), 'USER:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.user_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        18 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_rta_state_master') }} t0
    where (nullif(nullif('USER:' || nullif(trim(t0.user_name), ''), 'USER:'), '')) is not null

    union all

    -- branch 66: BJAZ_SCR_MOT_VEH_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.user_name, ''), '')))), '') as PARTY_BK,
        null,
        nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.user_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.owner_srno as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        t0.owner_srno as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE,
        19 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(md5(normalise(upper(nullif(coalesce(t0.user_name, ''), '')))), ''))) is not null

    union all

    -- branch 67: BJAZ_WAP_MOTOR_IW_ASSIST
    select
        null,
        nullif(nullif('SOS:' || nullif(trim(to_char(t0.sos_id)), ''), 'SOS:'), '') as CASE_BK,
        null,
        nullif(nullif('APPUSER:' || nullif(trim(t0.user_id), ''), 'APPUSER:'), '') as PARTY_BK,
        null, null, null,
        t0.pushed_yn as AUG_CASE_SERVICE_REQUEST__ASSISTANCE_OFFER_PUSHED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.assist_mode as CASE_SERVICE_REQUEST__SERVICE_REQUEST_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.customer_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        20 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_motor_iw_assist') }} t0
    where (coalesce(nullif(nullif('APPUSER:' || nullif(trim(t0.user_id), ''), 'APPUSER:'), ''), nullif(nullif('SOS:' || nullif(trim(to_char(t0.sos_id)), ''), 'SOS:'), ''))) is not null

    union all

    -- branch 68: BJAZ_WAP_MOTOR_IW_ASSIST | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(nullif('APPUSER:' || nullif(trim(t0.user_id), ''), 'APPUSER:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.mobile_no as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        20 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_motor_iw_assist') }} t0
    where (nullif(nullif('APPUSER:' || nullif(trim(t0.user_id), ''), 'APPUSER:'), '')) is not null

    union all

    -- branch 69: BJAZ_WAP_MOT_ADD_QSTN_DTLS
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif('PROPOSER:' || coalesce(to_char(t0.trans_id), ''), 'PROPOSER:')))), '') as PARTY_BK,
        nullif(nullif('WAP:' || nullif(trim(to_char(t0.trans_id)), ''), 'WAP:'), '') as PROPOSAL_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.driving_offence_score as AUG_PROPOSAL_UNDERWRITING__DRIVING_OFFENCE_SCORE,
        null,
        t0.partial_loss_score as AUG_PROPOSAL_UNDERWRITING__PARTIAL_LOSS_PROPENSITY_SCORE,
        t0.pin_condition as AUG_PROPOSAL_UNDERWRITING__PINCODE_ELIGIBILITY_CONDITION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.age as PARTY_IDENTITY__AGE,
        null, null,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        null,
        t0.profession as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        t0.bagic_mot_pol_yn as PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR,
        t0.claim_yn as PROPOSAL_DECLARATIONS__PREVIOUS_CLAIM_INDICATOR,
        null, null, null, null, null, null, null, null,
        21 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wap_mot_add_qstn_dtls') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif('PROPOSER:' || coalesce(to_char(t0.trans_id), ''), 'PROPOSER:')))), ''), nullif(nullif('WAP:' || nullif(trim(to_char(t0.trans_id)), ''), 'WAP:'), ''))) is not null

    union all

    -- branch 70: BJAZ_WS_MOTCLM_DETAILS
    select
        nullif(nullif(trim(t0.estimation_no), ''), '') as ASSESSMENT_BK,
        null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.advisor_name, '') || '|' || coalesce(t0.work_shop_id, ''), '|')))), '') as PARTY_BK,
        null, null,
        t0.record_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.advisor_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        22 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_details') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif(coalesce(t0.advisor_name, '') || '|' || coalesce(t0.work_shop_id, ''), '|')))), ''), nullif(nullif(trim(t0.estimation_no), ''), ''))) is not null

    union all

    -- branch 71: BJAZ_WS_MOTCLM_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=MOBILE
    select
        null, null, null,
        nullif(md5(normalise(upper(nullif(coalesce(t0.advisor_name, '') || '|' || coalesce(t0.work_shop_id, ''), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'MOBILE' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null, null, null,
        t0.advisor_contact as COMMON_CONTACT__MOBILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        22 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_details') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.advisor_name, '') || '|' || coalesce(t0.work_shop_id, ''), '|')))), '')) is not null

    union all

    -- branch 72: BJAZ_WS_MOTCLM_DETAILS | child-key literal(s): COMMON_CONTACT.Contact Point Type=EMAIL
    select
        null, null, null,
        nullif(nullif('WORKSHOP:' || nullif(trim(t0.work_shop_id), ''), 'WORKSHOP:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'EMAIL' as COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null, null, null,
        t0.dealer_mailid as COMMON_CONTACT__EMAIL_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        22 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_details') }} t0
    where (nullif(nullif('WORKSHOP:' || nullif(trim(t0.work_shop_id), ''), 'WORKSHOP:'), '')) is not null

)

select
    ASSESSMENT_BK,
    CASE_BK,
    DISTRIBUTION_CHANNEL_BK,
    PARTY_BK,
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_STATUS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    first_value(AUG_CASE_SERVICE_REQUEST__ASSISTANCE_OFFER_PUSHED_INDICATOR) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_SERVICE_REQUEST__ASSISTANCE_OFFER_PUSHED_INDICATOR,
    AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK,
    AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK,
    first_value(AUG_CHANNEL_SALES_TARGET__BORROWED_AMOUNT_BRANCH_OFFICE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__BORROWED_AMOUNT_BRANCH_OFFICE,
    first_value(AUG_CHANNEL_SALES_TARGET__BORROWED_AMOUNT_ZONAL_HEAD) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__BORROWED_AMOUNT_ZONAL_HEAD,
    first_value(AUG_CHANNEL_SALES_TARGET__BUDGETED_OWN_DAMAGE_PREMIUM) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__BUDGETED_OWN_DAMAGE_PREMIUM,
    first_value(AUG_CHANNEL_SALES_TARGET__BUDGET_AMOUNT_BRANCH_OFFICE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__BUDGET_AMOUNT_BRANCH_OFFICE,
    first_value(AUG_CHANNEL_SALES_TARGET__BUDGET_AMOUNT_ZONAL_HEAD) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__BUDGET_AMOUNT_ZONAL_HEAD,
    first_value(AUG_CHANNEL_SALES_TARGET__BUDGET_REFERENCE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__BUDGET_REFERENCE,
    first_value(AUG_CHANNEL_SALES_TARGET__CARRIED_FORWARD_AMOUNT_BRANCH_OFFICE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__CARRIED_FORWARD_AMOUNT_BRANCH_OFFICE,
    first_value(AUG_CHANNEL_SALES_TARGET__CARRIED_FORWARD_AMOUNT_ZONAL_HEAD) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__CARRIED_FORWARD_AMOUNT_ZONAL_HEAD,
    first_value(AUG_CHANNEL_SALES_TARGET__PORTFOLIO_GROUP_CODE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__PORTFOLIO_GROUP_CODE,
    first_value(AUG_CHANNEL_SALES_TARGET__RENEWAL_TYPE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__RENEWAL_TYPE,
    first_value(AUG_CHANNEL_SALES_TARGET__TARGET_YEAR) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__TARGET_YEAR,
    first_value(AUG_CHANNEL_SALES_TARGET__UTILISED_AMOUNT_BRANCH_OFFICE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__UTILISED_AMOUNT_BRANCH_OFFICE,
    first_value(AUG_CHANNEL_SALES_TARGET__UTILISED_AMOUNT_ZONAL_HEAD) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, AUG_CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, AUG_CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_SALES_TARGET__UTILISED_AMOUNT_ZONAL_HEAD,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__INTERNAL_INSURER_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__INTERNAL_INSURER_CODE,
    first_value(AUG_PROPOSAL_UNDERWRITING__DRIVING_OFFENCE_SCORE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_UNDERWRITING__DRIVING_OFFENCE_SCORE,
    first_value(AUG_PROPOSAL_UNDERWRITING__MANUAL_APPROVAL_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_UNDERWRITING__MANUAL_APPROVAL_INDICATOR,
    first_value(AUG_PROPOSAL_UNDERWRITING__PARTIAL_LOSS_PROPENSITY_SCORE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_UNDERWRITING__PARTIAL_LOSS_PROPENSITY_SCORE,
    first_value(AUG_PROPOSAL_UNDERWRITING__PINCODE_ELIGIBILITY_CONDITION) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_UNDERWRITING__PINCODE_ELIGIBILITY_CONDITION,
    first_value(AUG_PROPOSAL_UNDERWRITING__REFERRED_BY_REFERENCE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_UNDERWRITING__REFERRED_BY_REFERENCE,
    first_value(CASE_SERVICE_REQUEST__SERVICE_REQUEST_TYPE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_SERVICE_REQUEST__SERVICE_REQUEST_TYPE,
    CHANNEL_SALES_TARGET__TARGET_PERIOD_CK,
    CHANNEL_SALES_TARGET__TARGET_TYPE_CK,
    first_value(CHANNEL_SALES_TARGET__BUDGET_AMOUNT) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_SALES_TARGET__BUDGET_AMOUNT,
    first_value(CHANNEL_SALES_TARGET__BUDGET_PERCENTAGE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_SALES_TARGET__BUDGET_PERCENTAGE,
    first_value(CHANNEL_SALES_TARGET__TARGET_PERIOD) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_SALES_TARGET__TARGET_PERIOD,
    first_value(CHANNEL_SALES_TARGET__TARGET_TYPE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK, CHANNEL_SALES_TARGET__TARGET_PERIOD_CK, CHANNEL_SALES_TARGET__TARGET_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_SALES_TARGET__TARGET_TYPE,
    COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
    COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
    first_value(COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__ALTERNATE_EMAIL_ADDRESS,
    first_value(COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__ALTERNATE_MOBILE_NUMBER,
    first_value(COMMON_CONTACT__EMAIL_ADDRESS) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__EMAIL_ADDRESS,
    first_value(COMMON_CONTACT__LANDLINE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__LANDLINE_NUMBER,
    first_value(COMMON_CONTACT__MOBILE_NUMBER) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__MOBILE_NUMBER,
    first_value(COMMON_CONTACT__PREFERRED_CONTACT_TIME) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__PREFERRED_CONTACT_TIME,
    first_value(COMMON_CONTACT__WHATSAPP_OPT_IN_INDICATOR) ignore nulls over (partition by PARTY_BK, COMMON_CONTACT__CONTACT_POINT_TYPE_CK, COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONTACT__WHATSAPP_OPT_IN_INDICATOR,
    first_value(PARTY_IDENTITY__AGE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__AGE,
    first_value(PARTY_IDENTITY__DATE_OF_BIRTH) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__DATE_OF_BIRTH,
    first_value(PARTY_IDENTITY__FIRST_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__FIRST_NAME,
    first_value(PARTY_IDENTITY__GENDER_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__GENDER_CODE,
    first_value(PARTY_IDENTITY__LAST_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__LAST_NAME,
    first_value(PARTY_IDENTITY__MIDDLE_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__MIDDLE_NAME,
    first_value(PARTY_IDENTITY__NAME_SUFFIX) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__NAME_SUFFIX,
    first_value(PARTY_IDENTITY__PARTY_DISPLAY_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
    first_value(PARTY_IDENTITY__PARTY_FULL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_FULL_NAME,
    first_value(PARTY_IDENTITY__PARTY_LEGAL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
    first_value(PARTY_IDENTITY__PARTY_SUB_TYPE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_SUB_TYPE_CODE,
    first_value(PARTY_IDENTITY__PARTY_TYPE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_TYPE_CODE,
    first_value(PARTY_IDENTITY__SALUTATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__SALUTATION,
    first_value(PARTY_IDENTITY__TITLE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__TITLE_CODE,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_INCOME,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__HOUSE_OWNERSHIP_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__HOUSE_OWNERSHIP_TYPE,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__INDUSTRY_OF_EMPLOYMENT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__INDUSTRY_OF_EMPLOYMENT,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_CHILDREN) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_CHILDREN,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
    first_value(PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_DECLARATIONS__EXISTING_POLICY_INDICATOR,
    first_value(PROPOSAL_DECLARATIONS__PREVIOUS_CLAIM_INDICATOR) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_DECLARATIONS__PREVIOUS_CLAIM_INDICATOR,
    RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK,
    first_value(RISK_MOTOR_DRIVER__DRIVER_NAME) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_DRIVER__DRIVER_NAME,
    first_value(RISK_MOTOR_DRIVER__DRIVER_RELATIONSHIP) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_DRIVER__DRIVER_RELATIONSHIP,
    first_value(RISK_MOTOR_DRIVER__DRIVING_LICENCE_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_DRIVER__DRIVING_LICENCE_NUMBER,
    first_value(RISK_MOTOR_DRIVER__LICENCE_TYPE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_DRIVER__LICENCE_TYPE,
    first_value(RISK_MOTOR_DRIVER__OWNER_DRIVER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_DRIVER__DRIVER_LICENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_DRIVER__OWNER_DRIVER_INDICATOR,
    RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
    first_value(RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE
from merged
