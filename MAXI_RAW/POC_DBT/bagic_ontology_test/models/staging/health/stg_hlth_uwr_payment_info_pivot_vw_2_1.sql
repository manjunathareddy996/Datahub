{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW_2_1
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ACCOUNT_NUMBER2,
        EMANDATE_REGISTRATION,
        AN_AMOUNT_OF_RUPEES,
        PARTNER_CUST_ID,
        NAME_OF_THE_PREMIUM_PAYERNEW,
        NAME_OF_ACCOUNT_HOLDER,
        EMAIL_ID1,
        PAYMENT_FREQUENCY,
        TO_DEBIT,
        REFERENCE_NUMBER,
        DEBIT_TYPE1,
        PARTNER_CUST_ID1,
        BANK_CODE,
        EMAILID,
        DATE2,
        IFSC1,
        PERIOD_FROM_DATE,
        ACCOUNT_TYPE,
        PHONE_NUMBER1,
        ISPAYMENTPARTYSEARCH,
        DEBIT_TYPE,
        ACCOUNT_NUMBER1,
        UNTIL_CANCELLED1,
        AN_AMOUNT_OF_RUPEES1,
        PERIOD_TO,
        PAYMENT_MODE,
        BANK_IFSC_CODE,
        UTILITY_CODE1,
        WITH_BANK,
        UTILITY_CODE,
        PAYMENT_CYCLE_RAISED_TILL_DATE,
        AMOUNT1,
        IFSC,
        AUTODEBIT_FLAG,
        BUSINESS_TYPE,
        PERIOD_TO_DATE,
        TO_DEBIT1,
        PAYER_TYPE,
        TYPE_OF_BUSINESS,
        UNTIL_CANCELLED,
        ACCOUNT_NUMBER,
        WITH_BANK1,
        MICR,
        NAME_OF_THE_PREMIUM_PAYER,
        NAME_OF_THE_BANK,
        BANK_CITY,
        PHONE_NUMBER,
        MICR1,
        BRANCH_NAME_OUT,
        MICR_CODE,
        PERIOD_FROM,
        REFERENCE_NUMBER1,
        AMOUNT,
        DATE1,
        BANK_CODE1,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged