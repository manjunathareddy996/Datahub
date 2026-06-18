{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        COVER_NAME,
        TOTAL_PREMIUM_FOR_ACOVER_PRE_TAX,
        PERIOD_START_DATE,
        LOADING_DISCOUNT,
        MEMBER_NAME,
        PREMIUM_CALCULATION_DETAILS,
        GROSS_PREMIUM,
        PERIOD_END_DATE,
        COVER,
        PRORATED_PREMIUM,
        TOTAL_PREMIUM_FOR_POLICY_PRE_TAX,
        TOTAL_COVER_PERIOD,
        BASE_PREMIUM,
        DURATION,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged