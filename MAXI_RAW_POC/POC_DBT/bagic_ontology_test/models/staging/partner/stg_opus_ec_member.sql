{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS extended cover member details
-- Source: BJAZ_EC_MEM_DTLS_EXTN
-- Extended cover health product members
-- BK: PARTNER_ID + CONTRACT_ID + MEMBER_NO

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_EC_MEM_DTLS_EXTN') }}
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
        DEDUCTIBLE_AMT,

        -- Health flags
        SMOKER_YN,
        DIABETES_YN,
        HYPERTENSION_YN,
        ASTHMA_YN,
        MEDICAL_CHECKUP,
        MEDICAL_REPORT,
        AGE_PROOF,
        PREGNANT_YN,
        PREGNANT_MONTHS,
        SMOKE_CONSUMP,

        -- Biometric
        HEIGHT_CM,
        WEIGHT_KG,

        -- Previous policy
        PREV_COMPANY_NAME,
        PREV_SUM_INSURED,
        PERV_POL_EXP_DATE,
        FIRST_POLICY_REF,
        INCEPTION_DATE,
        PREV_POLICY_DTLS,
        DISEASE_DTLS,
        STATUS,
        HLTH_INS_POL_YRS,
        PRE_POL_NCB_PER,
        CLAIM_RECEIVED,
        CLAIMED_FOR,

        -- Concurrent policy
        CON_POLICY_REF,
        CON_COMPANY,
        CON_EXP_DATE,
        CON_SI,
        CON_DEDUCTABLE,
        EXPIRY_DATE,

        -- Health history
        FMLY_HLTH_COMPLAINS,
        ILLNESS_DURATION,
        PAST_4YR_ILLNESS,
        PAST_4YR_TREATMENT,
        PAST_4YR_TREAT_DATE,
        PRIOR_4YR_ILLNESS,
        PRIOR_4YR_TREATMENT,
        PRIOR_4YR_TREAT_DATE,
        PROPOSAL_REJECT_DTLS,

        -- Params
        COMMON_PARAM1,
        COMMON_PARAM2,
        EFFETIVE_DATE,

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
