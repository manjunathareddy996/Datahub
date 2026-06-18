{{
    config(
        materialized='view'
    )
}}

-- Staging: Partner relations (roles/stake codes)
-- Source: BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION
-- This gives us the STAKE_CODE for hub_prtnr_role

WITH source AS (
    SELECT *
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_RELATION') }}
),

-- Join back to party detail to get PARTY_CODE
party_detail AS (
    SELECT FOREIGN_KEY, PARTY_CODE
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL') }}
    WHERE PARTY_CODE IS NOT NULL
),

staged AS (
    SELECT
        pd.PARTY_CODE,
        src.STAKE_NAME,  -- Role name (POLICY-HOL, MEMBER, DFLTSTKIND, etc.)
        src.FOREIGN_KEY,
        src.ROOT_HASH,
        src.KEY_HASH,
        src.INC_JOB_CREATED_AT,
        src.REC_REFRESH_AT,
        
        -- Hash keys
        {{ hash('pd.PARTY_CODE') }} AS hk_prtnr_mstr_cd,
        
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source
        
    FROM source src
    LEFT JOIN party_detail pd ON src.FOREIGN_KEY = pd.FOREIGN_KEY
)

SELECT * FROM staged
