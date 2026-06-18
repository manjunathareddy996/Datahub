{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        VIEWPROPOSAL_NUMBER,
        TYPE_OF_PROPOSAL,
        RISK_EXPIRY_DATE,
        SUB_STATUS,
        RISK_START_DATE,
        PRODUCT_CODE,
        SOURCE,
        POLICY_NUMBER,
        PRODUCT_NAME,
        STATUS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged