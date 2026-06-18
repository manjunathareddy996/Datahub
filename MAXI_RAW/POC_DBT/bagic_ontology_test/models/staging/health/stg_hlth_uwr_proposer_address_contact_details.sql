{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        PIN_CODE,
        EMAIL3,
        MOBILE_NUMBER,
        FAX_NUMBER,
        EFFECTIVE_DATE,
        ADDRESS_LINE3,
        ADDRESS_LINE2,
        STATE_CODE,
        EMAIL1,
        TELEPHONE_NUMBER,
        TYPE_OF_CONTACT,
        DISTRICT_CODE,
        CITY_CODE,
        EMAIL2,
        ADDRESS_LINE1,
        COUNTRY_CODE,
        CONTACT_DETAILS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged