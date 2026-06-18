{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        MEMBER_DETAILS_TAB,
        MEMBER_DATA,
        GRADED_SI_DETAILS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged