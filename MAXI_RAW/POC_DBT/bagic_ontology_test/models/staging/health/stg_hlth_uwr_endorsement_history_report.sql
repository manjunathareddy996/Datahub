{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_ENDORSEMENT_HISTORY_REPORT
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_ENDORSEMENT_HISTORY_REPORT') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ENDORSEMENT_NO,
        ENDORSEMENT_TYPE,
        POLICY_NO,
        ENDORSEMENT_HISTORY_REPORT,
        EFFECTIVE_DATE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged