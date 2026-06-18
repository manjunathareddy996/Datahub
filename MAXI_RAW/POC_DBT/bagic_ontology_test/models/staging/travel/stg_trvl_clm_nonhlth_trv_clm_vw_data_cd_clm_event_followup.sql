{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP
-- Source: raw_travel_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_claim', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        KEYWORD,
        DESCRIPTION_REMARKS,
        PRIORITY_INDICATOR,
        LAST_UPDATED_BY,
        JOB_STATUS,
        ASSIGNED_PERSONAL,
        CLAIM_FOLLOWUP_STATUS,
        CREATED_DATE,
        CLAIM_EVENT_FOLLOWUP,
        LAST_UPDATED_DATE,
        EVENT_CODE,
        EVENT_EFFECTIVE_DATE,
        CREATED_BY,
        FOLLOWUP_TIMESTAMP,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged