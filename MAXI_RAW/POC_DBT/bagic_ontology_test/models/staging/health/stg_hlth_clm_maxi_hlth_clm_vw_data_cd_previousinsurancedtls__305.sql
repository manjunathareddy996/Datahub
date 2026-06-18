{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PREVIOUSINSURANCEDETAILS_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PREVIOUSINSURANCEDETAILS_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        NUMBER_OF_CLAIMS_LODGED,
        INSURER,
        PREVIOUS_POLICY_START_DATE,
        PREVIOUS_POLICY_EXPIRY_DATE,
        CUMULATIVE_BONUS_IN_PREVIOUS_POLICY,
        CONTINUITY_INDICATOR_APPROVED,
        SUM_INSURED_IN_PREVIOUS_POLICY,
        REMARKS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged