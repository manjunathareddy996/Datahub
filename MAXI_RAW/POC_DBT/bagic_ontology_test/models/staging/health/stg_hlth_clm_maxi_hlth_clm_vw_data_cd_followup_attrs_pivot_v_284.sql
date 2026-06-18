{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_FOLLOWUP_ATTRIBUTES_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_FOLLOWUP_ATTRIBUTES_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        SLA,
        TEAM_NAME,
        ACTION,
        TASK_STATUS,
        ASSIGNED_TO,
        COMPLETION_DATE,
        FOLLOW_UP_DATE,
        REMARKS,
        TASK_DESCRIPTION,
        CREATED_BY,
        QUEUE_NAME,
        PROCESS_NAME,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged