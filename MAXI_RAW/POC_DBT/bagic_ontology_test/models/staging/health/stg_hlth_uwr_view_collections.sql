{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        IMD_CODE,
        IMD_CHANNEL,
        SUB_CODE,
        MODE,
        NARRATION,
        COLLECTION_PAYMENT_TYPE,
        COLLECTION_PAYMENT_NUMBER,
        SOURCE_OF_COLLECTION,
        CHQ_INS_DATE,
        CHQ_INS_NUMBER,
        DRAWEE_BANK_BRANCH,
        SUB_IMD_CHANNEL,
        CHQ_INS_TYPE,
        IMD_CODE_NAME,
        VIEW_COLLECTIONS,
        AMOUNT_TO_BE_COLLECTED_PAID,
        CURRENCY,
        ACCOUNT_CODE,
        DATE_OF_POSTING,
        EFFECTIVE_DATE,
        REFERENCE_NO,
        DATE_OF_COLLECTION_PAYMENT,
        CURRENCY_RATE,
        CREDIT_ACCOUNT_CODE,
        COLLECTION_SUB_TYPE,
        AMOUNT,
        POLICY_QUOTATION_DEBIT_NOTE_NO,
        OTHER_APPROVED_SRC,
        POSTED_BY,
        CREATED_BY,
        COLLECTION_PAYMENT_AMOUNT,
        VOUCHER_NUMBER,
        DRAWEE_BANK_NAME,
        RECEIVED_FROM,
        SCROLL_DATE,
        SUB_IMD_CODE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged