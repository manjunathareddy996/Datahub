{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS hospital master
-- Source: BJAZ_HM_HOSPITAL_MASTER
-- Contains hospital network, discount, empanelment, speciality
-- BK: HOSID + PARTNER_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'BJAZ_HM_HOSPITAL_MASTER') }}
    WHERE PARTNER_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Keys
        PARTNER_ID AS PART_ID,
        {{ hash('PARTNER_ID') }} AS hk_prtnr_mstr_cd,
        HOSID,
        HOSPITAL_NO,

        -- Hospital identity
        HOSPITAL_NAME,
        CAST(HOSP_TYPE AS VARCHAR) AS HOSP_TYPE,
        HOSP_SPECIALITY,
        HOSP_SPEC_TYPE,
        NETWORK_TYPE,
        HOS_STATUS,
        BENNAME,

        -- Address / Contact
        ADDRESS1,
        ADDRESS2,
        CITY_NAME,
        STATE_NAME,
        PIN_CODE,
        STD_CODE,
        PHONE_NO,
        FAX_NO,
        EMAIL,
        CONTACT_PERSON,
        DESIGNATION,

        -- Commercial terms
        DISCOUNT,
        DISCOUNT_ON,
        EARLY_DISCOUNT,
        PAYMENT_MODE,
        STAX_REG_NO,
        DIAGNO_YN,
        PREFERRED_FLAG,
        PRIORITY_FLG,

        -- IMPS (Instant Managed Payment System)
        IMPS_ACTIVE_DATE,
        IMPS_END_DATE,
        IMPS_DISCNT,
        IMPS_DISCNT_ON,
        IMPS_TARIF_FRM,
        IMPS_TARIF_TO,
        IMPS_PAYMENT_LMT,

        -- Dates / Audit
        DATE_OF_SUP,
        EMPANEL_DATE,
        EFFECTIVE_DATE,
        EXPIRY_DATE,
        HOS_REMARK,
        DELETE_FLAG,
        UPDATED_ON,
        UPDATED_BY,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
