{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_MEMBER_STATUS_HISTORY
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_MEMBER_STATUS_HISTORY') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        REMARKS,
        MEMBER_SUB_STATUS,
        EFFECTIVE_DATE,
        USER,
        MEMBER_STATUS,
        MEMBER_STATUS_HISTORY,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged