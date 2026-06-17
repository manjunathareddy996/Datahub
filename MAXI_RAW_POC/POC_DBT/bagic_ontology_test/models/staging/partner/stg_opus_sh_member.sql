{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS senior health member details
-- Source: BJAZ_SH_MEM_DTLS_EXTN
-- Senior citizen health product members
-- BK: PARTNER_ID + CONTRACT_ID + MEMBER_NO

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_SH_MEM_DTLS_EXTN') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        CONTRACT_ID,
        POLICY_REF,
        MEMBER_NO,

        -- Member identity
        NAME,
        DATE_OF_BIRTH,
        AGE,
        GENDER,
        RELATION,
        OCCUPATION,
        GROSS_INCOME,
        ASSIGNEE,
        NOMINEE_RLTN,

        -- Coverage
        SUM_INSURED,
        PREMIUM,
        PREV_SUM_INSURED,
        CUMM_BONUS_PER,
        CUMM_BONUS,

        -- Health flags
        SMOKER_YN,
        DIABETES_YN,
        HYPERTENSION_YN,
        ASTHMA_YN,
        MEDICAL_CHECKUP,
        MEDICAL_REPORT,
        STATUS,

        -- Health details
        DISEASE_DTLS,
        PREV_POLICY_DTLS,
        CLAIM_HISTORY,
        COMPANY_NAME,
        AMOUNT_CLAIMED,
        POLICY_COLLECTED,
        WAITING_PERIOD,
        LOAD_RATE,
        LOAD_AMT,
        EFFETIVE_DATE,
        EXPIRY_DATE,

        -- Extended fields
        ADDRESS,
        EMAIL_ID,
        PERIOD_OF_INSURANCE,
        PERIOD_TREATMENT,
        DOCTOR_NAME,
        COMMENTS,
        FIRST_POLICY_REF,
        INCEPTION_DATE,

        -- Versioning
        ACTION_CODE,
        VERSION_NO,
        OBJECT_ID,
        TOP_INDICATOR,
        PREVIOUS_VERSION,
        REVERSING_VERSION,

        -- CDC (no explicit GG_CHANGE_DATE in this table — use ACTION_CODE for versioning)

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
