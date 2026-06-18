{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS Star package family floater member details
-- Source: BJAZ_STARPKG_FF_DTLS
-- Star Package product members
-- BK: PARTNER_ID + CONTRACT_ID + SR_NO

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_STARPKG_FF_DTLS') }}
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

        -- Member identity
        MEMBER_NAME,
        DOB,
        AGE,
        GENDER,
        RELATION,
        ASSIGNEE,
        PASSPORTNO,
        NOMINEE_RLTN,

        -- Coverage
        FULL_PREMIUM,
        FF_PREMIUM,
        RATE,
        RATE_FACTOR,
        YESNO,
        PRE_EXIST_DISEASE,
        SP_CONDITIONS,

        -- Add-ons
        CI_YN,
        CI_LOADING_PER,
        HC_YN,
        DEL_FLAG,

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
