{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS health care family member details
-- Source: BJAZ_HCF_MEMBER_DTLS
-- Family floater health product members
-- BK: PARTNER_ID + CONTRACT_ID + MEMBER_NO

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_HCF_MEMBER_DTLS') }}
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
        MONTHLY_INCOME,
        ASSIGNEE,
        ASSIGNEE_RELATION,

        -- Coverage
        SI_PLAN,
        SUM_INSURED,
        HOSP_CASH,
        CRITICAL_ILLNESS,
        PERSONAL_ACC,
        PREMIUM,
        ADON_PREMIUM,
        FLOAT_PREMIUM,
        FLOAT_ADDON,
        LOAD_PER,
        LOADING_REASON,
        LOADSUM_AMT,

        -- Health details
        PREEXIST_DICEASE,
        MED_REPORT_RECEIVED,
        REPORTS_NORMAL,
        SPECIAL_CONDITIONS,
        SMOKER_FLAG,
        ASTHMA_FLAG,
        HOLESTEROL_FLAG,
        HEART_FLAG,
        HIPERTENSION_FLAG,
        DIABETES_FLAG,
        HEIGHT_FLAG,
        WEIGHT_FLAG,
        AGE_PROOF_FLAG,
        MED_EXAM_FLAG,
        OBESITY_FLAG,
        BMI_FLAG,
        HYPERLIPIDE_FLAG,
        OTHER_RISK_FLAG,
        DIABETES_TYPE,

        -- Loading details
        OBESITY_LOAD,
        BMI_LOAD,
        HYPERTENS_LOAD,
        DIABETES_LOAD,
        HYPERLIPIDEMIA_LOAD,
        OTHER_RISK_LOAD,

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
        OTHER_REMARKS,
        ANCILIARY,

        -- Params
        PARAM1,
        PARAM2,
        PARAM3,

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
