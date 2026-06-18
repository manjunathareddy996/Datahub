{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PREVIOUS_POLICY_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PREVIOUS_POLICY_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        POLICY_NUMBER,
        PRODUCT_NAME,
        PREVIOUS_POLICY_DETAILS,
        PRODUCT_CODE,
        SUM_INSURED,
        TOTAL_PREMIUM,
        POLICY_EXPIRY_DATE,
        POLICY_INCEPTION_DATE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged