{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        POLICY_PROPERTY,
        MULTI_SET_PROPERTY,
        SIMPLE_PROPERTY,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged