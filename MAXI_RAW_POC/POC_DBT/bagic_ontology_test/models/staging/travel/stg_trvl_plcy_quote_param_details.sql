{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        COMMISSION,
        PARTY_CODES_FOR_REMOVAL,
        POLICY_DETAILS_CHANGE_INDICATOR,
        REFER_INDICATOR,
        POLICY_PROPERTY,
        POLICY_BRANCH_NAME,
        POLICY_INCEPTION_DATE,
        BASE_CURRENCY,
        ADDITIONAL_PARTY_LIST,
        TOTAL_DISCOUNT_AMOUNT,
        POLICY_EXPIRY_DATE,
        INTIMATION_DATE,
        APPLICATION_CODE,
        POLICY_TERM,
        POLICY_TERM_UNIT,
        CALCULATE_PREMIUM_INDICATOR,
        QUOTE_PARAM_DETAILS,
        PARTY_DETAILS,
        RISK_LIST,
        PREMIUM_CURRENCY,
        STRPRIVILEGE_CODE,
        AGENT_CODE,
        POL_PROP_PROP_LIST,
        UPDATE_PARTY_INDICATOR,
        PREMIUM_CURRENCY_RATE,
        DOCUMENT_ID,
        BUILDING_DETAILS,
        POLICY_STATUS_CODE,
        POLICY_HOLDER_CODE,
        BILLING_STAKE,
        PREMIUM_FREQUENCY,
        MULTITHREAD_INDICATOR,
        RET_CODE,
        TOTAL_LOADING_AMOUNT,
        PREMIUM_MODE,
        RET_ERROR,
        RISK_ID_FOR_REMOVAL,
        BASE_CURRENCY_RATE,
        NEW_PREM_INDICATOR,
        POLICY_QUOTE_NUMBER,
        PRODUCT_CODE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged