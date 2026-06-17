{{
    config(
        materialized='view'
    )
}}

-- Staging: Core partner detail (business key + core attributes)
-- Source: BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL

WITH source AS (
    SELECT *
    FROM {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL') }}
    WHERE PARTY_CODE IS NOT NULL
),

staged AS (
    SELECT
        -- Business Key
        PARTY_CODE,
        
        -- Core attributes
        BUSINESS_NAME,
        CREATED_BY,
        DATE_OF_BIRTH,
        FIRST_NAME,
        GENDER,
        LAST_NAME,
        MIDDLE_NAME,
        NATIONALITY,
        OCCUPATION,
        PARENT_PARTY_CODE,
        PARTY_END_DATE,
        PARTY_LAST_MODIFICATION_DATE,
        PARTY_START_DATE,
        PARTY_STATUS,
        REGISTRATION_DATE,
        REGISTRATION_NO,
        TITLE,
        TYPE_OF_ORGANIZATION,
        TYPE_OF_PARTY,
        
        -- Metadata
        FOREIGN_KEY,
        ROOT_HASH,
        KEY_HASH,
        RECORD_HASH,
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        
        -- Hash keys for Data Vault
        {{ hash('PARTY_CODE') }} AS hk_prtnr_mstr_cd,
        
        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source
        
    FROM source
)

SELECT * FROM staged
