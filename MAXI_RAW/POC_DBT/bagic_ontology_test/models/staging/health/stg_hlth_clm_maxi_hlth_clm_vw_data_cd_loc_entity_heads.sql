{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ENTITY_GRID_ROWS,
        ENTITY_HEAD_CODE,
        ENTITY_HEAD_NAME,
        ENTITY_TYPE,
        ENTITY_HEADS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged