{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_DOCUMENTS_DOCUMENT_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_DOCUMENTS_DOCUMENT_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        DOCUMENT_SIZE,
        UPLOAD_STATUS,
        ADHOC_DOC_TYPE,
        DOCUMENT_BELONGS_TO,
        CREATED_ON,
        DOCUMENT_ID,
        DOCUMENT_TYPE,
        DOCUMENT_NAME,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged