{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS partner history (SCD2 source)
-- Source: BJAZ_CP_PART_HIST
-- Versioned partner attributes — use for satellite historization
-- BK: PART_ID + VERSION

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_CP_PART_HIST') }}
    WHERE PART_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        CAST(PART_ID AS VARCHAR) AS PART_ID,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,

        -- Identity
        SURNAME,
        FIRST_NAME,
        MIDDLE_NAME,
        NAME,
        SHORT_NAME,
        INSTITUTION_NAME,
        BEFORE_TITLE,
        AFTER_TITLE,
        PARTNER_TYPE,
        PARTNER_REF,
        DATE_OF_BIRTH,
        DATE_OF_DEATH,
        CAUSE_OF_DEATH,
        PROOF_OF_DEATH,
        SEX,
        NATIONALITY,
        MARITAL_STATUS,
        OCCUPATION,
        EMPLOYMENT_STATUS,
        LANGUAGE,
        LEGAL_FORM,
        DATA_STATUS,
        DNI,
        NATIONAL_ID,
        TAX_ID,
        VAT_NUMBER,
        REG_NUMBER,
        EVID_TYPE,
        EVIDENCE,

        -- Contact
        TELEPHONE,
        TELEPHONE2,
        EMAIL,
        FAX,
        CONTACT1,
        CONTACT2,
        QUALITY,

        -- Address
        ADD_ID,
        ADDRESSEE,
        FROM_DATE,

        -- LUA
        LUA_VALUE_1,
        LUA_VALUE_2,
        LUA_VALUE_3,
        LITERATURE,
        NOTES,

        -- Version control
        VERSION,
        EVENT_DATE,
        USERID,
        EXT_USER,

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
