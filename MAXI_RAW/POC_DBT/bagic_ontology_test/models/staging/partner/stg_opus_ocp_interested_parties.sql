{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS OC policy interested parties
-- Source: OCP_INTERESTED_PARTIES
-- Links partners to policies (party roles in a policy)
-- BK: CONTRACT_ID + IP_NO + PARTNER_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'OCP_INTERESTED_PARTIES') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        CONTRACT_ID,
        IP_NO,

        -- Attributes
        CUSTOMER_NAME_TEXT,
        MAILING_ADDRESS_ID,

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
