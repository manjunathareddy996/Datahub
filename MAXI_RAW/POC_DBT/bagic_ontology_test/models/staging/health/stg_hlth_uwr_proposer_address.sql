{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        CONTACT_DETAILS,
        PROPOSER_ADDRESS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged