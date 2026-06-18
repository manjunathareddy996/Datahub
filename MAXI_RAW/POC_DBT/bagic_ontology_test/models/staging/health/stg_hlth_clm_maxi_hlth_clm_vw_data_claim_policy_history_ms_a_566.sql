{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        VIEWINWARD_NUMBER,
        SOURCE,
        CLAIMED_AMOUNT,
        TYPE_OF_CLAIM,
        CLAIM_NUMBER,
        STATUS,
        APPROVED_AMOUNT,
        DATE,
        POLICY_NUMBER,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged