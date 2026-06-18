{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS health corporate member (legacy BA table)
-- Source: BA_HCP_DT_MEM
-- Legacy health corporate policy member data
-- BK: PART_ID + CONTRACT_ID + MEM_SEQNO
-- Note: Most columns are COL1..COL100 (generic) — only named columns are included

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BA_HCP_DT_MEM') }}
    WHERE PART_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PART_ID,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,
        CONTRACT_ID,
        HCP_SEQNO,
        MEM_SEQNO,

        -- Member identity
        MEMBER_NAME,
        USER_ID,
        ENTRY_DATE,
        MEM_STATUS,
        MEM_ADD_FLAG,

        -- Coverage
        PREM_BASE_COVER,

        -- Versioning
        ACTION_CODE,
        VERSION_NO,
        OBJECT_ID,
        TOP_INDICATOR,
        PREVIOUS_VERSION,
        REVERSING_VERSION,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
