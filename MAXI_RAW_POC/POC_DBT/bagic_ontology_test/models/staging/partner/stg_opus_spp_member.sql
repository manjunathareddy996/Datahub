{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS super plus member details
-- Source: BJAZ_SPP_MEMBER_DTLS
-- Super Plus product members
-- BK: PARTNER_ID + CONTRACT_ID + MEMBER_NO

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_SPP_MEMBER_DTLS') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        CONTRACT_ID,
        MEMBER_NO,

        -- Member identity
        INSURED_NAME,
        DATE_OF_BIRTH,
        AGE,
        GENDER,
        RELATION,
        MEMBER_OCCUPATION,
        ASSIGNEE,
        ASSIGNEE_RELATION,

        -- Coverage
        SI_PLAN,
        SUM_INSURED,
        HOSP_CASH,
        CRITICAL_ILLNESS,
        PERSONAL_ACC,
        PREMIUM,
        LOAD_PER,
        LOADING_REASON,
        TOT_MEMBER_LOADING,

        -- Health details
        PREEXIST_DICEASE,
        MED_REPORT_RECEIVED,
        REPORTS_NORMAL,
        SPECIAL_CONDITIONS,
        DIABETES,
        HYPERTENSION,
        CHOLESTEROL_DISORDER,
        OBESITY,
        CARDIOVASCULAR_DISEASES,
        OTHER_OCC,

        -- Biometric
        HEIGHT_FEET,
        HEIGHT_INCHES,
        WEIGHT,
        BMI,

        -- Previous policy
        COMPANY_NAME,
        POLICY_NUMBER,
        PREVIOUS_SI,
        FROM_DATE,
        TO_DATE,
        CUMULATIVE_BNOUZ_PER,
        CUMULATIVE_AMT,
        PREV_POLICY_SINCE,
        CONCURRENT_POLICY_DETAILS,
        DECEASE_TREATMENT_DTLS,
        CLAIM_DTLS,

        -- Versioning
        ACTION_CODE,
        VERSION_NO,
        OBJECT_ID,
        TOP_INDICATOR,
        PREVIOUS_VERSION,
        REVERSING_VERSION,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
