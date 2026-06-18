{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        DOCUMENT_ID,
        POL_RISK_ID,
        STATE_CODE,
        RISK_SERIAL_NUMBER,
        RISK_LIST,
        BILLING_STAKE,
        RISK_CODE,
        RISK_COVER,
        RISK_EXPIRY_DATE,
        ADDR3,
        PARTY_CODE,
        COUNTRY_CODE,
        POLICY_ID,
        ADDITIONAL_PARTY_CODE,
        RISK_PROPERTY,
        MULTI_SET_PROPERTY_INPUT,
        PREM_CURRENCY,
        ADDR1,
        CITY_CODE,
        RISK_SUM_INSURED,
        POLICY_COUNTRY,
        LOADING,
        PARTY_DETAILS,
        BASE_CURRENCY,
        RISK_DESC,
        DISCOUNT,
        POSTAL_CODE,
        ADDR2,
        RISK_INCEPTION_DATE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged