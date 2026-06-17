{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS partner extension history (SCD2 source)
-- Source: BJAZ_AZBJ_PART_EXT_HIST
-- Versioned partner extension attributes
-- BK: PART_ID (inferred from matching columns with AZBJ_PARTNER_EXTN)

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_AZBJ_PART_EXT_HIST') }}
    WHERE PART_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        CAST(PART_ID AS VARCHAR) AS PART_ID,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,

        -- Employee / Agent
        EMP_ID,
        PA_CODE,
        SUBCODE,

        -- Family
        FATHER_NAME,
        PLACE_OF_BIRTH,
        EDUCATION,
        OCCUPATION_DESC_GEN,

        -- Organisation
        GLOBAL_CO_NAME,
        PARENT_CO,
        PARENT_ID,
        CO_NUMBER,
        INDUSTRY,
        PAIDUP_CAPITAL,

        -- Bank / Financial
        IFSC_CODE,
        MICR_CODE,
        ACC_TYPE,
        ACCOUNT_NO,
        ECS_STATUS,

        -- Contact
        TELEPHONE3,
        EMAIL_2,
        PARTNER_REF_NO,
        MAIL_ADD_ID,

        -- Membership
        AA_MEMBERSHIP_NUMBER,
        AA_MEMBERSHIP_EXPIRY_DATE,

        -- Flags
        IT_STATUS,
        VIP_CUST,
        EIA_NO,
        AVAILABILITY_TIME,
        AVAILABILITY_AT,

        -- Audit
        UPD_DT,
        USER_NAME,
        MACHINE,
        PROGRAM,
        WEB_USER_ID,
        ACTION,
        MODULE,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
