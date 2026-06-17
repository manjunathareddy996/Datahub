{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS claim supplier extension
-- Source: BJAZ_CLM_SUPP_EXTN
-- Contains surveyor, repairer, lawyer, dealer role-specific attributes
-- BK: SUPP_ID + PARTNER_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_CLM_SUPP_EXTN') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        SUPP_ID,

        -- Location
        LOC_CODE,
        LOCATION_CODE,
        COVERED_AREA,
        CO_ORD_ADDRESS1,
        CO_ORD_ADDRESS2,
        BILLING_STATE,
        BILLING_LOC,
        COUNTRY,
        COUNTRY_CODE,
        BAGIC_LOCATION,
        BAGIC_OFFICE_ADDRESS,
        OPERATION_PLACE,

        -- Contact
        MOBILE_NO,
        STD_CODE,
        EMAIL_ID,
        SUPP_EMAIL,
        SUPP_MOBILE,
        PHONE_DETAILS,
        CONTACT_PERSON_NAME,
        CONTACT_PERSON_MOB1,
        CONTACT_PERSON_MOB2,

        -- Financial
        FEES,
        SUPP_BANK_NAME,
        SUPP_BANK_ACC_NO,
        ANN_TURNOVER,
        PAN_NO,
        PAN_STATUS,
        PAN_ACK_DT,
        PAN_APP_NO,
        TAXPAYER_TYPE,
        TCS_STATUS,
        TAN_NUMBER,

        -- License / Certification
        LICENSE_NO,
        IRDA_LICENSE,
        SURVEYOR_LICENSE_NO,
        SUR_LICENSE_EXP_DATE,
        GRADE,
        CLASS,
        SURVEYOR_CATEGORY,

        -- Intermediary
        IMD_CODE,
        SUB_IMD_CODE,
        DEALER_CODE,
        EMPCODE,

        -- Workshop / Repairer
        WORKSHOP_CATEGORY,
        WORKSHOP_NAME,
        WORKSHOP_CLASS,
        MFG_CO_NAME,
        SPEC_REPAIRER,
        TOWING_VEHICLE,
        NO_TOWING_VEHICLE,

        -- Lawyer / Legal
        LAWYER_TYPE,
        BAR_ASSOCIATION_NAME,
        ENROLMENT_NO,
        COVERED_COURT_LOC,
        DATE_OF_JOINING,
        YR_EXPERIENCE,
        NO_OF_BRIEFS,
        NO_OF_CONSUMER,
        NO_OF_JUNIOR,
        NO_OF_WC,
        NO_OF_MACT,
        NO_OF_COMPANIES,
        ACD_QUALIFICATION,
        INTERNET_ACCESS,
        ACCESS_ONLINE_JOURNAL,
        AVAILABILITY_LIBRARY,

        -- Ownership / Company
        OWNERS_NAME,
        OWNERS_MIDDLE_NAME,
        OWNERS_SUR_NAME,
        OWNERS_FULL_NAME,
        ORIGIN_COMP,
        COMP_TYPE,
        ORIGIN_CONT,
        PARENT_CO_NAME,
        PARENT_CO_ADD_LINE1,
        PARENT_CO_ADD_LINE2,
        PARENT_CO_ADD_LINE3,
        ESTABLISH_YEAR,
        CON_EXPERTISE,
        SUPP_OWNERSHIP,
        SUPP_SCOPE,
        OWNRSHIP_DEPT,

        -- Hospital / MOU
        MOU_STATUS,
        SUR_MODULE_LOGIN,

        -- LOB expertise flags
        EXP_LOB_FIRE_FLG,
        EXP_LOB_MARIN_CARGO_FLG,
        EXP_LOB_MOTOR_FLG,
        EXP_LOB_MISCELL_FLG,
        EXP_LOB_MARINE_HULL_FLG,
        EXP_LOB_ENGINEERING_FLG,
        EXP_LOB_LOSS_PROFIT_FLG,
        EXP_LOB_WORKMAN_COMP_FLG,

        -- Flags
        LVS_FLAG,
        IRN_FLAG,
        TWO_YR_ITR_FLAG,
        ADHAAR_PAN_LINK_FLAG,
        EW_WHITE_GOODS_FLG,
        TP_MIGRATION_YN,
        ON_DUTY_FLAG,
        CLAIM_NEAR_ME_FLAG,
        JW_FLAG,
        DEDUCTIBLE_EXEMPT,

        -- Misc
        PRIORITY,
        MSME_CLASS,
        IIISLA_MEM_NO,
        IIISLA_MEM_STATUS,
        RMK_IF_ANY,
        REMARKS,
        INVOICE_PATTERN,
        OTHER_BAGIC_BUSINESS,
        JW_ID,
        DUTY_FLAG_UPDATE_DATE,
        MRG_ANNIVERSIRY,

        -- Dates
        EXPIRY_DATE,

        -- Audit
        LAST_EDIT_DATE,
        LAST_EDIT_BY_USER,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
