{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        CLAIM_POLICY_HISTORY,
        AUTHORIZATION_REMARKS,
        POLICY_CLAIM_HISTORY,
        PENAL_INTEREST,
        RESPONSE,
        CLAIM_DETAIL,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged