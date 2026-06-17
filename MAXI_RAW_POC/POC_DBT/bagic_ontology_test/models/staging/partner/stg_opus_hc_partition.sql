{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS health claim partition extension
-- Source: BJAZ_HC_PART_EXTN
-- Health claim partition (member risk details per section)
-- BK: PART_ID + CONTRACT_ID + PARTITION_NO

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_HC_PART_EXTN') }}
    WHERE PART_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PART_ID,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,
        CONTRACT_ID,
        PARTITION_NO,

        -- Member identity
        MEMBER_NAME,
        DATE_OF_BIRTH,
        DATE_OF_BIRTH_M,
        AGE,
        SEX,
        RELATION,
        OCCUPATION,
        ASSIGNEE_NAME,

        -- Coverage
        SUM_INSURED,
        PREMIUM,
        LOAD_RATE,
        LOAD_AMT,
        BENEFIT_OPTED,
        NO_OF_DAYS,
        RATE_STATUS,
        WAITING_PERIOD,
        AMOUNT_CLAIMED,
        CLAIM_HISTORY,

        -- Health
        DISEASE_DTLS,
        HOSPITAL,
        HOSPITAL_DETAIL,
        PRESCRIPTION,
        PRESCRIPTION_DETAIL,
        STATUS,

        -- Previous policy
        FIRST_POLICY_REF,
        INCEPTION_DATE,
        NOMINEE_RLTN,

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
