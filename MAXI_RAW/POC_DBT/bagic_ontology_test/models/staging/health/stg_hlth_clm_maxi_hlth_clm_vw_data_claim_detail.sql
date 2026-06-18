{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        CLAIM_COPAY_DETAILS,
        RELATIONS,
        CLAIM_ADJUST,
        CLAIM_DETAIL,
        POL_POLICY_NUMBER,
        CLAIM_RESERVE,
        CLAIMBENEFITLIMIT,
        REOPEN_INDICATOR,
        CLAIMDETAIL_ATTRIBUTE,
        DOCUMENTS,
        REQUIREMENTS,
        CLAIM_PARTYDETAILS,
        PREVIOUSINSURANCEDETAILS,
        CLAIMINWD_DOCUMENTS,
        PREVIOUSINSURANCEDETAIL,
        CLAIM_PARTY,
        CLAIM_PAYMENT,
        CLAIM_RESERVE_HISTORY,
        CLAIM_NUMBER,
        CANCELLATION_DATE,
        STATUS,
        PACKAGEANDSERVICE,
        LIST_OF_COVERS,
        CLAIMTRANSITION,
        RENEWAL_FLAG,
        FOLLOWUP,
        TOTAL_CLAIMED_AMOUNT,
        NOTES,
        QUERY_DETAILS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged