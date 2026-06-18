{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        TELE_VARIFICATION_INITIATED_DATE,
        END_TIME,
        START_TIME,
        TRANSACTION_ID,
        TELE_VERIFICATION_DETAILS,
        TELE_VARIFICATION_STATUS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged