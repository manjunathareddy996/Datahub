{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        MOBILE_NUMBER,
        STATE_CODE,
        EMAIL2,
        EMAIL1,
        CITY_CODE,
        ADDRESS_LINE1,
        TYPE_OF_CONTACT,
        EFFECTIVE_DATE,
        ADDRESS_LINE3,
        FAX_NUMBER,
        COUNTRY_CODE,
        TELEPHONE_NUMBER,
        CONTACT_DETAILS,
        ADDRESS_LINE2,
        EMAIL3,
        PIN_CODE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged