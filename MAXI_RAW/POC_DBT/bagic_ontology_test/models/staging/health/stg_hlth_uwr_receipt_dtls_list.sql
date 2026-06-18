{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_RECEIPT_DETAILS_LIST
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_RECEIPT_DETAILS_LIST') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        CREATED_ON,
        RECEIPT_DETAILS_LIST,
        INSTRUMENT_NUMBER,
        RECEIPT_NUMBER,
        UPDATED_ON,
        CREATED_BY,
        INSTRUMENT_MODE,
        INSTRUMENT_STATUS,
        INSTRUMENT_DATE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged