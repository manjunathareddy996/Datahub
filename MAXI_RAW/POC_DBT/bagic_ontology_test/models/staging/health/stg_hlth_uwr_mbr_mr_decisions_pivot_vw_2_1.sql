{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW_2_1
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DECISIONS_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        USG,
        SYSTEM_DECISION,
        UNDERWRITING_LOADING_PERCENTAGE,
        POSITIVEHEALTHDECLARATION,
        SI_ENHANCEMENT_REJECTED,
        AUDITOR_DECISION,
        2D_ECO,
        TERMSOFACCEPTANCEANDREJECTION,
        CTMT_DECISION,
        GENERAL_REMARKS,
        XRAY,
        ANY_OTHER_ADDITIONAL_TEST,
        DECLARE_HEALTH_HISTORY,
        BMI_DECISION,
        ECG_DECISION,
        FULL_MEDICAL_REPORT,
        LOADING_REASON,
        TYPE_OF_UNDERWRITING_LOADING,
        LABORATORY_REPORT,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged