{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS
-- Source: raw_travel_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_claim', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        LOSSDATE,
        CLAIM_ATTRIBUTE,
        CLAIM_NOTIFICATION_DETAILS,
        CLAIMBRANCH,
        SECONDARYCAUSEDESC,
        STATUSCHANGEDATE,
        CLAIM_PAYMENT,
        CLAIM_HISTORY,
        CLAIM_NOTES,
        CLAIMNO,
        CLAIM_SURVEYOR_DEPUTATION,
        CLAIM_RISK_PARTY,
        CLAIM_TRIGGER_DETAILS,
        LOSSDESC,
        PRIMARYCAUSEDESC,
        CLAIM_COVER,
        DOCUMENT_DETAILS,
        CLAIM_RISK,
        CLAIM_RESERVE,
        SUBCLAIMNO,
        CLAIM_EVENT_FOLLOWUP,
        VAHAN_REGISTRATION_VERIFIED,
        SAVING_AMOUNT,
        INTIMATIONDATE,
        PRIMARYCAUSECODE,
        POLICYNO,
        CLAIM_PARTY,
        CLAIM_BUCKET,
        CLAIMSTATUS,
        CLAIM_DETAILS,
        NET_ASSESSED_AMOUNT,
        SECONDARYCAUSECODE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged