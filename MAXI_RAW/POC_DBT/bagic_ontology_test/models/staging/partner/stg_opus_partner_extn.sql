{{
    config(
        materialized='view'
    )
}}

-- Staging: OPUS partner extension attributes
-- Source: AZBJ_PARTNER_EXTN
-- Contains bank, KYC, family, employment, contact details
-- BK: PART_ID

WITH source AS (
    SELECT *
    FROM {{ source('raw_opus', 'AZBJ_PARTNER_EXTN') }}
    WHERE PART_ID IS NOT NULL
),

staged AS (
    SELECT
        -- Business Key
        CAST(PART_ID AS VARCHAR) AS PART_ID,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,

        -- Employee / Agent
        EMP_ID,
        PA_CODE,
        SUBCODE,

        -- Family
        FATHER_NAME,
        SPOUSE_NAME,
        NO_OF_CHILDREN,
        SONS,
        DAUGHTERS,
        FAMILY_MONTHLY_INCOME,
        FAMILY_ID,

        -- Personal
        PLACE_OF_BIRTH,
        EDUCATION,
        OCCUPATION_DESC_GEN,

        -- Organisation
        GLOBAL_CO_NAME,
        PARENT_CO,
        PARENT_ID,
        CO_NUMBER,
        INDUSTRY,
        PAIDUP_CAPITAL,

        -- Bank / Financial
        IFSC_CODE,
        MICR_CODE,
        ACC_TYPE,
        ACCOUNT_NO,
        ECS_STATUS,

        -- Contact
        TELEPHONE3,
        EMAIL_2,
        ALT_MOBILE_NO,
        ALT_EMAIL_ID,
        PREFERRED_CONTACT_OPT,
        MAIL_ADD_ID,

        -- Membership
        AA_MEMBERSHIP_NUMBER,
        AA_MEMBERSHIP_EXPIRY_DATE,

        -- Flags / Status
        IT_STATUS,
        EXISTING_CUST,
        WEBSITE,
        UCIC_FLAG,
        HNI_FLAG,
        VIP_CUST,
        MSME_FLAG,

        -- References
        PARTNER_REF_NO,
        CLUSTER_ID,
        EIA_NO,
        TRF_TO_BANCS,
        BANCS_PART_ID,
        UNIQUE_ID,
        POLICY_REF,
        EXISTING_POLICY_PID,

        -- Audit
        FROM_MODULE,
        SYSTEM_IP,
        USERNAME,
        STATUS,
        AVAILABILITY_TIME,
        AVAILABILITY_AT,

        -- CDC
        GG_CHANGE_DATE,

        -- Load metadata
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'OPUS' AS record_source

    FROM source
)

SELECT * FROM staged
