{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBERS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        GROSS_PREMIUM,
        MEDICALRATING,
        MEMBER_DETAILS,
        FOLLOW_UP_REPORT,
        QUESTIONNAIRE,
        PPC_PACKAGE,
        NET_PREMIUM,
        BENEFITS,
        MEDICAL_DIGITIZATION,
        EXPIRY_DATE,
        PARTY,
        REQUIREMENT_DETAILS,
        MEDICAL_DETAILS,
        INCEPTION_DATE,
        MEMBERS,
        ADDITIONAL_TEST,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged