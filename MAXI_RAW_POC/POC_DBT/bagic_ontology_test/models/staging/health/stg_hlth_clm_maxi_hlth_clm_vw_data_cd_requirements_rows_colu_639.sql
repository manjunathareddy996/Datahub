{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_REQUIREMENTS_ROWS_COLUMNS_CHILD_ROWS_ROWS_COLUMNS_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        MEDICALTECHNICAL,
        CHASER_STATUS,
        REMARKS,
        REQUIREMENT_STATUS,
        CHASER_DOCUMENT,
        REQUIREMENT_DETAILS,
        SEQUENCE_NO,
        MANDATORYOPTIONAL,
        DOCUMENT_TITLE,
        MODIFIED_DATE,
        MODIFIED_BY,
        DOCUMENTS_UPLOADED_DATE,
        SOURCE_OF_DOCUMENT,
        UPLOADED_REQUIREMENT,
        REQUIRED_IN,
        CHASER_DATE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged