{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_PARTY_DETAILS
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_PARTY_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        MULTI_SET_ATTRIBUTE,
        PARTY_DETAILS,
        ATTRIBUTES,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged