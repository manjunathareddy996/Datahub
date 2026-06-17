{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS address history (SCD2 source)
-- Source: BJAZ_CP_ADD_HIST
-- Versioned address attributes
-- BK: ADD_ID + VERSION

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_CP_ADD_HIST') }}
    WHERE ADD_ID IS NOT NULL
),

partner AS (
    SELECT PART_ID, ADD_ID
    FROM {{ source('raw_opus', 'CP_PARTNERS') }}
    WHERE PART_ID IS NOT NULL
      AND ADD_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        CAST(p.PART_ID AS VARCHAR) AS PART_ID,
        {{ hash('p.PART_ID') }} AS hk_prtnr_mstr_cd,

        -- Address
        src.ADD_ID,
        src.ADDRESS_LINE1,
        src.ADDRESS_LINE2,
        src.ADDRESS_LINE3,
        src.ADDRESS_LINE4,
        src.ADDRESS_LINE5,
        src.POSTCODE,
        src.COUNTRY_CODE,
        src.TELEPHONE,
        src.FROM_DATE,

        -- Version control
        src.VERSION,
        src.EVENT_DATE,
        src.USERID,
        src.EXT_USER,

        -- Audit
        src.UPD_DT,
        src.USER_NAME,
        src.MACHINE,
        src.PROGRAM,
        src.WEB_USER_ID,
        src.ACTION,
        src.MODULE,

        -- CDC
        src.GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source src
    INNER JOIN partner p ON src.ADD_ID = p.ADD_ID
)

SELECT * FROM staged
