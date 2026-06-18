{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS personal accident detail extension
-- Source: BJAZ_PA_DETL_EXTN
-- Personal accident product member/risk details
-- BK: PARTNER_ID + CONTRACT_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_PA_DETL_EXTN') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        CONTRACT_ID,
        REF_NO,

        -- Member identity
        MEMBER_NAME,
        DOB,
        AGE,
        RELATION,
        ASSIGNEE,
        RISK_CLASS,

        -- Coverage
        SUM_INSU_BASIC,
        SUM_INSU_WIDER,
        SUM_INSU_COMP,
        MEDICAL_EXP,
        MEDICAL_CON,

        -- Loading
        LOAD_RATE,
        LOAD_AMT,
        CUMMULATIVE_BONUS,
        CUMMULATIVE_AMT,
        CUMM_BONUS_COMP,
        CUMM_BONUS_WIDER,
        CUMM_BONUS_AMT_WIDER,
        CUMM_BONUS_AMT_COMP,

        -- Previous
        FIRST_POLICY_REF,
        INCEPTION_DATE,

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
