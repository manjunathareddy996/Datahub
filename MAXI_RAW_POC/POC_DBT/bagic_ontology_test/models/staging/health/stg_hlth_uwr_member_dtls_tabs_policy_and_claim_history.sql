{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_POLICY_AND_CLAIM_HISTORY
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TABS_POLICY_AND_CLAIM_HISTORY') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        SOURCE,
        STATUS,
        RISK_EXPIRY_DATE,
        PRODUCT_NAME,
        POLICY_NUMBER,
        TYPE_OF_PROPOSAL,
        SUB_STATUS,
        VIEW_PROPOSAL_NUMBER,
        RISK_START_DATE,
        POLICY_AND_CLAIM_HISTORY,
        PRODUCT_CODE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged