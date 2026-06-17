{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS contingency family floater member details
-- Source: BJAZ_CTNGY_FF_DTLS_EXTN
-- Contingency/family floater product members
-- BK: PARTNER_ID + CONTRACT_ID + SR_NO

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_CTNGY_FF_DTLS_EXTN') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        CONTRACT_ID,
        SECTION_CODE,
        SR_NO,
        SCHEME_CODE,
        SCHEME_VERSION,

        -- Member identity
        MEMBER_NAME,
        DOB,
        GENDER,
        RELATION,
        NOMINEE_RELATION,
        ASSIGNEE,
        PASSPORTNO,

        -- Coverage
        PREMIUM,
        RATE,
        RATE_FACTOR,
        YESNO,
        PRE_EXIST_DISEASE,
        TRACKED_DATE,

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
