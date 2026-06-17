{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        LANDLINE_NO,
        EMAIL_ID,
        STD_CODE,
        COUNTRY,
        FAX,
        ADDRESS3,
        ADDRESS1,
        ADDRESS2,
        PHONE_NO,
        CITY,
        ALTERNATE_EMAIL_ID,
        WORK_NO,
        ADDRESS_PROPERTY,
        ADDRESS_TYPE,
        MOBILE_NO,
        STATE,
        DISTRICT,
        PINCODE,
        OFFICE_ADDRESS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged