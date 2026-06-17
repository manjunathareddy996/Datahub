{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_QUERY_DETAILS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        MODIFIED_DATE,
        REMARKS,
        CHASER_DATE,
        UPLOADED_DOCUMENTS,
        DOCUMENT_TITLE,
        REQUIREMENT_STATUS,
        RAISED_DATE,
        SEQUENCE_NO,
        REQUIREMENT_DETAILS,
        CHASER_DOCUMENT,
        RAISED_BY,
        MEDICALTECHNICAL,
        CHASER_STATUS,
        MODIFIED_BY,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged