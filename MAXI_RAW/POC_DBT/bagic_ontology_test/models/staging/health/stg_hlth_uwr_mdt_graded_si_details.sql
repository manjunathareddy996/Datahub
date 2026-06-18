{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB_GRADED_SI_DETAILS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB_GRADED_SI_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        REMARKS,
        CUMULATIVE_SI_CB,
        EXPIRY_DATE,
        WAITING_PERIOD_ELASPED_IN_YEARS,
        CB,
        GRADED_SI,
        START_DATE,
        SI,
        GRADED_SI_DETAILS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged