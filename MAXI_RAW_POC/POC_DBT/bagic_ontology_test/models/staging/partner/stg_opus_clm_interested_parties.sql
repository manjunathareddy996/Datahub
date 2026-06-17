{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS claim interested parties
-- Source: CLM_INTERESTED_PARTIES
-- Links partners to claims (party roles in a claim)
-- BK: CLAIM_ID + IP_NO + PART_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'CLM_INTERESTED_PARTIES') }}
    WHERE PART_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PART_ID,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,
        CLAIM_ID,
        IP_NO,
        
        -- Attributes
        IP_TYPE,
        CLAIMANT,
        OBJECT_TYPE,
        INS_OBJ_UID,
        
        -- Versioning
        VERSION_NO,
        OBJECT_ID,
        
        -- CDC
        GG_CHANGE_DATE,
        
        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source
        
    FROM source
)

SELECT * FROM staged
