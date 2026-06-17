{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ADDRESS1,
        ALTERNATE_EMAIL_ID,
        PHONE_NO,
        ADDRESS_PROPERTY,
        CITY,
        LANDLINE_NO,
        COUNTRY,
        ADDRESS_TYPE,
        STD_CODE,
        PINCODE,
        ADDRESS2,
        PARTY_ADDRESS,
        WORK_NO,
        STATE,
        ADDRESS3,
        EMAIL_ID,
        FAX,
        DISTRICT,
        MOBILE_NO,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged