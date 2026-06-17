{{config(materialized='view')}}

-- Staging: Multi-set property pivot (role-specific attributes)
-- Source: BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW_2_1
-- This contains attributes that vary by partner role (STAKE_CODE)

WITH source AS (
    SELECT *
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW_2_1') }}
    WHERE STAKE_CODE IS NOT NULL
      AND STAKE_CODE != ''
),

-- Join to get PARTY_CODE
party_detail AS (
    SELECT 
        PARTY_CODE,
        FOREIGN_KEY,
        TYPE_OF_PARTY,
        PARTY_STATUS
    FROM {{ ref('stg_partner_detail') }}
),

staged AS (
    SELECT
        pd.PARTY_CODE,
        pd.TYPE_OF_PARTY,
        pd.PARTY_STATUS,
        
        -- Hash keys
        {{ hash('pd.PARTY_CODE') }} AS hk_prtnr_mstr_cd,
        {{ hash(['pd.PARTY_CODE', 'src.STAKE_CODE']) }} AS hk_prtnr_role_cd,
        
        -- All business columns from multi-set pivot (including STAKE_CODE)
        src.* EXCLUDE (FOREIGN_KEY, INC_JOB_CREATED_AT, REC_REFRESH_AT, STAKE_CODE),
        
        -- Role identifier (explicitly after EXCLUDE to avoid duplicate)
        src.STAKE_CODE,
        
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
