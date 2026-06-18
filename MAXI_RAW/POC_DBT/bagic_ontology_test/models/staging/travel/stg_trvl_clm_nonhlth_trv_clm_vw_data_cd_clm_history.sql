{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY
-- Source: raw_travel_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_claim', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        CLAIM_STATUS,
        CLAIM_SUB_STATUS,
        DETAILS,
        REMARKS,
        TYPE,
        PPI_INDICATOR,
        REFERENCE_NUMBER,
        CLAIM_HISTORY,
        EVENT_DESCRIPTION,
        CREATED_DATE,
        DELAY_REASON,
        SURVEY_REPORT_STATUS,
        EVENT_DATE,
        SCRUTINY_STATUS,
        USER_CODE,
        EVENT,
        CLAIM_REQUIREMENT_STATUS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged