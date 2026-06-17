{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ADDRESS_LINE_3,
        PINCODE1,
        NEFT_STATUS,
        REFERENCE_NO,
        UTR_DATE,
        IFSC_CODE,
        PAYEE_ADDRESS,
        APPROVED_DATE,
        TYPE_OF_BENEFICIARY,
        PERCENTAGE_FOR_PAYMENT,
        TDS_1,
        CHEQUE_SERVICING_STATE,
        EMIRATESSTATEP,
        ACCOUNT_TYPE,
        ROLE,
        BANK_NAME,
        PAYMENT_PURPOSE,
        STATUSES,
        REIMBURSEMENT_PREFERENCES,
        ADDRESS_LINE_1,
        DDCHEQUE_REFERENCE,
        BANK_DETAILS1,
        ACCOUNT_NUMBER,
        PAYMENT_APPROVED_DATE,
        INVOLVING_PARTY,
        UTR_NUMBER,
        BANK_CITY,
        STATUS_CODE,
        MOBILE_NUMBER,
        ADDRESS_LINE_2,
        PAYMENT_AMOUNT,
        IMPACTED_COVER,
        BRANCH_NAME1,
        CHEQUE_DD_RELEASE_DATE,
        START_DATE,
        EMAIL_ID,
        GST_AMOUNT,
        INOUT,
        PAYBLE_AT,
        ADDRESS_SAME_AS_POLICY_HOLDER,
        STATUS,
        PAN_NO,
        APPROVED_BY_,
        PAYMENT_DATE1,
        END_DATE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged