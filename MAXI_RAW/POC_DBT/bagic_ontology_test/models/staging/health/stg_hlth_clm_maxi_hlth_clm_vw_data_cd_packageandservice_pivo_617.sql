{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PACKAGEANDSERVICE_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PACKAGEANDSERVICE_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        DURATION_TO,
        PRICE_PER_UNIT,
        CURRENCY,
        LAST_UPDATED_BY,
        DURATION_FROM,
        EFFECTIVE_DATE,
        TYPE_OF_ROOM,
        SERVICE_CODE,
        CHARGE_HEAD,
        SERVICE_DESCRIPTION,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged