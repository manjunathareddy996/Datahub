{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS health mediclaim member details
-- Source: BJAZ_HM_MEMBER_DTLS
-- Group/retail health member — richest member table
-- BK: PARTNER_ID + CONTRACT_ID + MEMBER_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_HM_MEMBER_DTLS') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        CONTRACT_ID,
        MEMBER_ID,
        POLICY_REF,

        -- Member identity
        MEMBER_NAME,
        DOB,
        AGE,
        GENDER,
        RELATION,
        OCCUPATION,
        DESIGNATION,
        EMAIL_ID,
        PHONE_NO,
        ADDRESS,
        PIN,
        CITY,
        STATE,

        -- Coverage
        SUMINSURED,
        BONUS_SI,
        PREMIUM,
        -- ADON_PREMIUM,
        PLAN_NAME,
        PRODUCT_CODE,
        RISK_CLASS,
        GRADE,

        -- Employment
        HAT_EMPCODE,
        CO_EMPNUMBER,
        EMPLOYEE_LOCATION,
        MONTHLY_SALARY,

        -- Bank
        BANK_AC_NO,
        BANK_NAME,
        MICR_CODE,

        -- Health details
        LOAD_RATE,
        LOAD_AMT,
        CUMM_BONUS_PER,
        CUMM_BONUS,
        GROSS_INCOME,
        HC_NO_OF_DAYS,
        ASSIGNEE_NAME,

        -- Status / ID
        MEMBER_STATUS,
        ID_CARD_NO,
        MEMBER_FLAG,
        VIP_FLG,
        OLD_MEMBER_NO,
        CLAIM_COUNT,
        -- FLOAT_PREMIUM,
        -- FLOAT_ADDON,

        -- Endorsement
        ENDORSEMENT_NO,
        ENDORSEMENT_DATE,
        ADD_ENDORSEMENT_NO,
        DEL_ENDORSEMENT_NO,
        REFUND_PREMIUM,

        -- Dates
        TERM_START_DATE,
        TERM_END_DATE,
        PROCESS_DATE,
        DATA_RECEIVED_DATE,
        DATE_SENT_TO_VENDOR,

        -- Group policy link
        CTNY_INFOVIEW_FLAG,
        CTNY_MASTER_CONTRACT_ID,
        OLD_TABLE_NAME,
        DELETE_FLAG,

        -- Audit
        USER_NAME,
        UPDATED_ON,
        UPDATED_BY,

        -- Versioning
        ACTION_CODE,
        VERSION_NO,
        OBJECT_ID,
        TOP_INDICATOR,
        PREVIOUS_VERSION,
        REVERSING_VERSION,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
