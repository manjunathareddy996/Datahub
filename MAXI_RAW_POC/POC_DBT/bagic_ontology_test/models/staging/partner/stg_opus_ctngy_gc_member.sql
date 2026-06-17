{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS contingency group corporate member data
-- Source: BJAZ_CTNGY_GC_MEM_DATA
-- Group corporate member information
-- BK: PARTNER_ID + POLICY_REF

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_CTNGY_GC_MEM_DATA') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        MASTER_POLICY_REF,
        POLICY_REF,

        -- Member identity
        MEMBER_NAME,
        GENDER,
        DATE_OF_BIRTH,
        AGE,
        RELATION,
        INSURED_ADDRESS,
        TELEPHONE,
        PLAN_NAME,

        -- Coverage
        SUM_INSURED,
        POLICY_ISSUE_DATE,
        RISK_INCEPTION_DATE,
        RISK_EXPIRY_DATE,

        -- Extra
        EXTRA_COL1,
        EXTRA_COL2,
        INFOVIEW_FLAG,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
