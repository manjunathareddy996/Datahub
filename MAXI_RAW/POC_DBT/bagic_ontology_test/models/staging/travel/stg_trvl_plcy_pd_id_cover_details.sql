{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        NET_PREMIUM,
        EVENT_CODE,
        COVER_INCEPTION_DATE,
        COVER_NAME,
        COVER_DETAILS,
        COVER_PROPERTY,
        TOTAL_PREMIUM,
        COVER_EXPIRY_DATE,
        COVER_CODE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged