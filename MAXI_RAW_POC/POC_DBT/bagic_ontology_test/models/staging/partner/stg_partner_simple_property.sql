{{
    config(
        materialized='view'
    )
}}

-- Staging: Simple property pivot (1049 partner attributes as columns)
-- Source: BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
-- This is the main source for most partner satellite attributes

WITH source AS (
    SELECT *
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1') }}
),

-- Join to get PARTY_CODE
party_detail AS (
    SELECT FOREIGN_KEY, PARTY_CODE, PARTY_STATUS, TYPE_OF_PARTY
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL') }}
    WHERE PARTY_CODE IS NOT NULL
),

staged AS (
    SELECT
        pd.PARTY_CODE,
        pd.PARTY_STATUS,
        pd.TYPE_OF_PARTY,
        
        -- Hash keys
        {{ hash('pd.PARTY_CODE') }} AS hk_prtnr_mstr_cd,
        
        -- All business columns from the pivot table
        src.* EXCLUDE (FOREIGN_KEY, INC_JOB_CREATED_AT, REC_REFRESH_AT),
        
        -- Metadata
        src.FOREIGN_KEY,
        src.INC_JOB_CREATED_AT,
        src.REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source
        
    FROM source src
    INNER JOIN party_detail pd ON src.FOREIGN_KEY = pd.FOREIGN_KEY
)

SELECT * FROM staged
