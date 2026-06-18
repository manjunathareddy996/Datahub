{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        VALUE,
        MULTI_SET_ATTRIBUTE,
        NAME,
        PARTY_DETAILS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged