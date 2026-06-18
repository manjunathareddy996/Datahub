{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS health ensure member details
-- Source: BJAZ_HLT_ENSURE_MEM_DTLS
-- Health Ensure product members
-- BK: PARTNER_ID + CONTRACT_ID + MEMBER_NO

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_HLT_ENSURE_MEM_DTLS') }}
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
        NAME,
        DATE_OF_BIRTH,
        AGE,
        GENDER,
        RELATION,
        ASSIGNEE,
        NOMINEE_RLTN,

        -- Coverage
        SUM_INSURED,
        PRE_DISEASE,
        SPECIAL_CONDITION,
        AGE_PROOF_YN,
        DELETE_MEM,

        -- Previous policy
        PREV_POLICY_NO,
        PREVIOUS_COMPANY_NAME,
        PREVIOUS_POLICY_NO,
        PREVIOUS_SUM_INSURED,
        PREVIOUS_FROM_DATE,
        PREVIOUS_TO_DATE,
        PREVIOUS_CUM_BONUS,
        PREVIOUS_CUM_AMOUNT,
        PREVIOUS_SINCE_NOOF_YEARS,
        FIRST_POLICY_NUMBER,
        FIRST_POL_INCEPTION_DATE,

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
