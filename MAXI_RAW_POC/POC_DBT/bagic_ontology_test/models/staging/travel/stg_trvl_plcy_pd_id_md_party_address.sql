{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ADDRESS1,
        ADDRESS3,
        PHONE_NO,
        CITY,
        PINCODE,
        PARTY_ADDRESS,
        STATE,
        FAX,
        ADDRESS_TYPE,
        ADDRESS_PROPERTY,
        ALTERNATE_EMAIL_ID,
        DISTRICT,
        ADDRESS2,
        EMAIL_ID,
        MOBILE_NO,
        WORK_NO,
        LANDLINE_NO,
        COUNTRY,
        STD_CODE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged