{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        DISTRICT_CODE,
        EMAIL3,
        EMAIL1,
        TYPE_OF_CONTACT,
        ADDRESS_LINE3,
        EFFECTIVE_DATE,
        EMAIL2,
        COUNTRY_CODE,
        CONTACT_DETAILS,
        FAX_NUMBER,
        ADDRESS_LINE2,
        STATE_CODE,
        ADDRESS_LINE1,
        PIN_CODE,
        MOBILE_NUMBER,
        TELEPHONE_NUMBER,
        CITY_CODE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged