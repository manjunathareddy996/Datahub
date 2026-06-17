{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS intermediary (agent) details
-- Source: BJAZ_INTERMEDIARY
-- Contains license, channel, region, commission arrangement
-- BK: INTERMEDIARY_ID + PARTNER_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_INTERMEDIARY') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        INTERMEDIARY_ID,

        -- Classification
        INTERMEDIARY_TYPE,
        INTERMEDIARY_GROUP,
        INTERMEDIARY_NAME,
        INTERMEDIARY_BAND,
        BUSINESS_CHANNEL,
        NEW_BC,
        NEW_IMD_TYPE,
        SUB_CHANNEL_CODE,
        SUB_CHN_EFF_DATE,
        FIN_SUB_CHANNEL_CODE,
        SPL_INTER_CODE,

        -- License
        LICENSE_NO,
        LICENSE_TYPE,
        LICENSE_EXPIRY_DATE,
        LICENSE_ISSUE_DATE,
        IRDA_INTERMEDIARY_CODE,
        IRDA_LICENSE_NO,

        -- Region / Location
        REGION_CODE,

        -- Financial
        PAN_NUMBER,
        TDS_RATE_IND,
        SPL_TDS_RATE,
        SHORT_COL_RATE,
        TYPE_OF_COMM_ARR,

        -- GST
        GST_STATUS,
        GST_NO,

        -- Compliance
        NATURE_OF_AGREEMENT,
        NATURE_OF_AGREEMENT_OTHER,
        PAN_AADHAR_LINKED,
        IT_RETURN_2YR,
        FLAGGING,
        REMARKS_CODE,

        -- Flags
        SUBIMD_YN,
        BLOCK_FOR_RECEIPT,
        GREEN_CHANNEL_IMD,
        IMDFLAG,

        -- Logo / Web
        LOGO_FILENAME,
        ISACTIVE_LOGO,
        WEBSITE_LINK,

        -- Status / Audit
        STATUS,
        USERNAME,
        SYSTEM_DATE,
        UPDATED_ON,
        TYPE_OF_CHANGE,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
