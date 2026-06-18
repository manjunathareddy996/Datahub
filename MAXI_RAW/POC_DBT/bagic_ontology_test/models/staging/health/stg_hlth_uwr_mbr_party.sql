{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        PARTY,
        INDV_OR_ORG,
        NATIONALITY,
        EFFECTIVE_DATE,
        CONTACT_DETAILS,
        OCCUPATION,
        PARTY_STATUS,
        FIRST_NAME,
        SEX,
        LAST_NAME,
        DATE_OF_BIRTH,
        MIDDLE_NAME,
        COMPANY,
        BUSINESS_NAME,
        PARTY_CODE,
        PARENT_PARTY_CODE,
        CITIZENSHIP_ID,
        INITIAL,
        FULL_NAME,
        PARTY_DETAILS,
        OTHER_NAME,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged