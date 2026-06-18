{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS claim supplier base
-- Source: CLM_SUPPLIERS
-- Contains supplier type, status, location
-- BK: SUPP_ID + PART_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'CLM_SUPPLIERS') }}
    WHERE PART_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PART_ID,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,
        SUPP_ID,

        -- Supplier attributes
        SUPP_TYPE,
        SUPP_STATUS,
        EFF_DATE,
        EXP_DATE,
        CONTACT,
        COMMENTS,
        LOC_CODE,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
