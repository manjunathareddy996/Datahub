{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        TOTAL_PREMIUM,
        COVER_DETAILS,
        RISK_DESC,
        RISK_SERIAL_NUMBER,
        RISK_PROPERTY,
        INSURED_DETAILS,
        SUM_INSURED,
        DOCUMENT_DETAILS,
        NET_PREMIUM,
        RISK_CODE,
        MEMBER_DETAILS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged