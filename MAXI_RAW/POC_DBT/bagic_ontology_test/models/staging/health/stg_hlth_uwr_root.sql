{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        NOTESDETAILS,
        PREMIUM_DETAILS,
        POLICY_EXPIRY_DATE,
        POLICY_BRANCH,
        BASE_CURRENCY,
        REQUIREMENT_DETAILS,
        DOCUMENTDETAILS,
        COMMUNICATIONDETAILS,
        ENDORSEMENT_DETAILS,
        MEMBER_DETAILS_TAB,
        PREMIUM_DEPOSIT_MODE,
        PREMIUM_CURRENCY,
        POLICY_SUB_STATUS,
        RECEIPT_DETAILS_LIST,
        ENDORSEMENT_HISTORY_REPORT,
        VIEW_COLLECTIONS_ADDITIONAL_DETAILS,
        PAYMENT_INFO,
        FOLLOW_UPDETAILS,
        RELATIONS,
        PREMIUM_CALCULATION_DETAILS,
        COMMUNICATION_DETAILS_ADDITION_TAB,
        POLICY_TERM,
        PRODUCT_CODE,
        BASIC_DETAIL_ATTRIBUTE,
        PROPOSER_ADDRESS,
        PRODUCT_NAME,
        POLICY_TERM_UNIT,
        PREMIUM_FREQUENCY,
        MEMBER_RIDER_DETAILS,
        MEMBER_DETAILS_TABS,
        POLICY_NUMBER,
        PROPOSAL_NUMBER,
        RENEWALDETAILS,
        VIEW_COLLECTIONS,
        POLICY_INCEPTION_DATE,
        MEDICAL_STATUS,
        USER_CODE,
        POLICY_PAYMENT_CYCLE_DETAILS,
        MEMBERS,
        POLICY_STATUS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged