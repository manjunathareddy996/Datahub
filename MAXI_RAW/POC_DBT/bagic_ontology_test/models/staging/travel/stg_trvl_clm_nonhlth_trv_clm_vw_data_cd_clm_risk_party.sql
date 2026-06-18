{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_PARTY
-- Source: raw_travel_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_claim', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_PARTY') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        BUSINESS_NAME,
        STAKECODE,
        PTYATTR,
        FIRSTNAME,
        LASTNAME,
        NIF,
        CLAIM_RISK_PARTY,
        PARTYCODE,
        MIDDLENAME,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged