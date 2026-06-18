{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        COMMISION,
        PREMIUM_MODE,
        POLICY_DURATIONUNIT,
        DISPATCH_DETAILS,
        AGENT_CODE,
        TELE_VERIFICATION_DETAILS,
        NET_PREMIUM,
        POLICY_PROPERTY,
        GST,
        POLICY_STATUS,
        PRODUCT_NAME,
        POLICY_INTIMATION_DATE,
        STAMP_DUTY,
        PRODUCT_CODE,
        POLICY_NUMBER,
        POLICY_INCEPTION_DATE,
        RENEWAL_FLAG,
        DOCUMENT_DETAILS,
        POLICY_PAYMENT_INFORMATION,
        ENDORSEMENT_DETAILS,
        OFFICE_DETAILS,
        POLICY_BRANCH_NAME,
        WORK_ITEM_DETAILS,
        POLICY_RELATION,
        POLICY_DURATION,
        POLICY_HOLDER_CODE,
        INSURED_DETAILS,
        POLICY_DETAILS,
        POLICY_EXPIRY_DATE,
        TOTAL_PREMIUM,
        PAYMENT_FREQUENCY,
        PREVIOUS_POLICY_DETAILS,
        PROPOSER_DETAILS,
        QUOTATION_NUMBER,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged