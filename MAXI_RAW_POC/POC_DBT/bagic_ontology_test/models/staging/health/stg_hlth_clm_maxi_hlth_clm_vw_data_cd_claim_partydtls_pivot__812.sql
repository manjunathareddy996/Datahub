{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ADDRESS_SAME_AS_POLICY_HOLDER,
        IRDA_CATEGORY,
        CLAIM_KYC_COMPLIANCE_DONE,
        MOBILE_NO,
        CHEQUE_SERVICING_STATE,
        PINCODE1,
        ACCOUNT_TYPE,
        DIFFERENTIAL_TDS,
        EMAIL_ID,
        ADDRESS_LINE_3,
        EMIRATESSTATEP,
        SERVICE_TAX_APPLICABLE,
        LOB,
        TDS_TYPE,
        SERVICE_TAX_REGISTRATION_NUMBER,
        LICENSE_NUMBER,
        ADDRESS_LINE_2,
        PERCENTAGE_FOR_PAYMENT,
        BANK_DETAILS1,
        LICENSE_EXPIRY_DATE,
        ADDRESS_LINE_1,
        PAYBLE_AT,
        ACCOUNT_NUMBER,
        IFSC_CODE,
        NEFT_STATUS,
        LICENSE_REGISTRATION_DATE,
        BRANCH_NAME1,
        START_DATE,
        TYPE_OF_BENEFICIARY,
        PAN_NUMBER,
        END_DATE,
        BANK_NAME,
        REIMBURSEMENT_PREFERENCES,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged