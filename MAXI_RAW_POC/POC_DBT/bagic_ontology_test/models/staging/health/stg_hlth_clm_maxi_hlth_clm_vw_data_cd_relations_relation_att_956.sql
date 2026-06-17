{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW_2_1
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        TDS_TYPE,
        LICENSE_REGISTRATION_DATE,
        LOB,
        ACCOUNT_TYPE,
        EMAIL_ID,
        ACCOUNT_NUMBER,
        BANK_NAME,
        BANK_DETAILS1,
        PAYBLE_AT,
        SERVICE_TAX_REGISTRATION_NUMBER,
        END_DATE,
        PERCENTAGE_FOR_PAYMENT,
        ADDRESS_LINE_1,
        BRANCH_NAME1,
        ADDRESS_SAME_AS_POLICY_HOLDER,
        ADDRESS_LINE_2,
        ADDRESS_LINE_3,
        SERVICE_TAX_APPLICABLE,
        MOBILE_NO,
        PAN_NUMBER,
        DIFFERENTIAL_TDS,
        TYPE_OF_BENEFICIARY,
        PINCODE1,
        LICENSE_EXPIRY_DATE,
        IFSC_CODE,
        NEFT_STATUS,
        START_DATE,
        LICENSE_NUMBER,
        REIMBURSEMENT_PREFERENCES,
        CLAIM_KYC_COMPLIANCE_DONE,
        EMIRATESSTATEP,
        IRDA_CATEGORY,
        CHEQUE_SERVICING_STATE,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged