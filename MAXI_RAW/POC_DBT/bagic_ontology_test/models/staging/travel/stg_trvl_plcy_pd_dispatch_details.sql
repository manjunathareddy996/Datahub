{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_DISPATCH_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_DISPATCH_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        DISPATCH_STATUS,
        DISPATCH_DETAILS,
        POD_NUMBER,
        DISTRICT,
        STATE,
        PRIORITY,
        ADDRESS,
        RECIPIENT_NAME,
        DISPATCH_DESTINATION,
        CITY,
        DISPATCH_MODE,
        REMARKS,
        SERIAL_NO,
        DISPATCH_DATE,
        PIN_CODE,
        DOCUMENT_TYPE,
        COURIER_NAME,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged