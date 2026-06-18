{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS core partner identity
-- Source: CP_PARTNERS (equivalent to MAXIMUS PARTY_DETAIL)
-- BK: PART_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'CP_PARTNERS') }}
    WHERE PART_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Business Key
        CAST(PART_ID AS VARCHAR) AS PART_ID,

        -- Hash key (same grain as MAXIMUS hub_prtnr_mstr)
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,

        -- Core identity attributes
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

        -- Contact
        TELEPHONE,
        TELEPHONE2,
        EMAIL,
        FAX,
        CONTACT1,
        CONTACT2,

        -- Identification
        TAX_ID,
        VAT_NUMBER,
        NATIONAL_ID,
        DNI,
        REG_NUMBER,
        EVID_TYPE,
        EVIDENCE,

        -- Address reference
        ADD_ID,
        ADDRESSEE,
        FROM_DATE,

        -- LUA / custom
        LUA_VALUE_1,
        LUA_VALUE_2,
        LUA_VALUE_3,
        QUALITY,
        LITERATURE,
        NOTES,

        -- Versioning
        VERSION,
        EVENT_DATE,
        USERID,
        EXT_USER,
        LAST_CHANGE_DATE,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
