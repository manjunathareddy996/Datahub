{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        COMPANY,
        BUSINESS_NAME,
        OCCUPATION,
        SEX,
        EFFECTIVE_DATE,
        PARTY_DETAILS,
        OTHER_NAME,
        FULL_NAME,
        DATE_OF_BIRTH,
        PARENT_PARTY_CODE,
        INITIAL,
        FIRST_NAME,
        CITIZENSHIP_ID,
        PARTY,
        INDV_OR_ORG,
        LAST_NAME,
        PARTY_CODE,
        NATIONALITY,
        CONTACT_DETAILS,
        PARTY_STATUS,
        MIDDLE_NAME,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged