{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMINWD_DOCUMENTS_ROWS_COLUMNS_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMINWD_DOCUMENTS_ROWS_COLUMNS_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        UPLOADED_INWARD_DOCUMENT,
        INWARD_DOCUMENT_RECEIVED,
        INWARD_DOCUMENT_DOWNLOADED,
        INWARD_DOCUMENT_LIST,
        NUMBER_OF_PAGES,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged