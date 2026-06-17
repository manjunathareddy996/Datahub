{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        COUNTRY_CODE,
        EMAIL2,
        FAX_NUMBER,
        EMAIL1,
        ADDRESS_LINE2,
        PIN_CODE,
        EMAIL3,
        MOBILE_NUMBER,
        TELEPHONE_NUMBER,
        ADDRESS_LINE3,
        ADDRESS_LINE1,
        CONTACT_DETAILS,
        STATE_CODE,
        CITY_CODE,
        EFFECTIVE_DATE,
        TYPE_OF_CONTACT,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged