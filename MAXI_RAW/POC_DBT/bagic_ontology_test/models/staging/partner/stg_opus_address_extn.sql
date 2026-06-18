{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS address extension
-- Source: AZBJ_ADDRESS_EXTN
-- Additional address attributes not in CP_ADDRESSES
-- Joined via ADD_ID → CP_PARTNERS for PART_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'AZBJ_ADDRESS_EXTN') }}
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
        CAST(p.PART_ID AS VARCHAR) AS PART_ID,
        {{ hash('p.PART_ID') }} AS hk_prtnr_mstr_cd,

        -- Address extension fields
        src.ADD_ID,
        src.ADD_TYPE,
        src.VALID_ADD,
        src.RESIDENCE_COUNTRY,
        src.COUNTRY,
        src.DOOR_NO,
        src.BUILDING_NAME,
        src.PLOT_STREET_NO,
        src.ADDRESS_LINE6,
        src.ADDRESS_LINE7,

        -- Contact
        src.TELEPHONE_NO1,
        src.TELEPHONE_NO2,
        src.CONTACT_DTLS,

        -- KYC
        src.PASSPORT_NO,

        -- Family (denormalized into address)
        src.SPOUSE_NAME,
        src.FAMILY_INCOME,
        src.NO_SON,
        src.NO_DAUGHTER,

        -- Policy reference
        src.P_POLICY_FLAG,
        src.POLICY_REF,
        src.PRPOSER_FLAG,
        src.PRPOSER_DTLS,

        -- Misc
        src.UNIQUE_ID,
        src.OTHER_DETAILS,

        -- CDC
        src.GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source src
    INNER JOIN partner p ON src.ADD_ID = p.ADD_ID
)

SELECT * FROM staged
