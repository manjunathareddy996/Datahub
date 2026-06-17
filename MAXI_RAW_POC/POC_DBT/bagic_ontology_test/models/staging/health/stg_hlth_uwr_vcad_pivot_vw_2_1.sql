{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS_ADDITIONAL_DETAILS_PIVOT_VW_2_1
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS_ADDITIONAL_DETAILS_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        REVERSE_ID,
        DISHONOUR_REASON,
        CARD_TYPE,
        CARD_TRANS_NO,
        CARD_TRANS_DATE,
        ISSUING_BANK,
        ACTION_BY,
        CHEQUE_ISSUED_BY_NAME,
        RECEIVED_DATE,
        RECEIPT_STATUS,
        IFSC_CODE,
        MICR_CODE,
        REALISATION_DATE,
        PAYER_BANK_ACCOUNT_NO,
        MINIMUM_PREMIUM_TO_BE_COLLECTED,
        EXCESS,
        ACTION_ON_CHEQUE,
        CARD_EXPIRY_DATE,
        MOBILE_NUMBER,
        ACTION_DATE,
        DISHONOUR_ID,
        PGIREFNO,
        CHILD_POLICY,
        CITY_NAME,
        REVERSE_REASON,
        CARD_NUMBERLAST_4_DIGITS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged