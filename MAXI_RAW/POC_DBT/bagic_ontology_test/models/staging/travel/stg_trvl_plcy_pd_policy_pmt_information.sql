{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        CHEQUE_STATUS,
        RECEIPT_GENERATION_DATE,
        SUB_CODE,
        COLLECTION_MODE,
        RECEIPT_NUMBER,
        TRANSACTION_DATE,
        COLLECTION_AMOUNT,
        TRANSACTION_ID,
        CHEQUE_REALISATION_DATE,
        COLLECTION_DATE,
        CHEQUE_NUMBER,
        POLICY_PAYMENT_INFORMATION,
        COLLECTION_TYPE,
        COLLECTION_SOURCE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged