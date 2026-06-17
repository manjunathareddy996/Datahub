{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
-- Source: raw_health_claim

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_claim', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        OCCUPATION,
        INITIAL,
        STAKEHOLDER,
        DATEOF_BIRTH,
        FIRST_NAME,
        PARENT_PARTY_CODE,
        CITIZENSHIP_ID,
        EFFECTIVE_DATE,
        CONTACT_DETAILS,
        PARTY,
        LAST_NAME,
        PARTY_CODE,
        COMPANY,
        MIDDLE_NAME,
        OTHER_NAME,
        NATIONALITY,
        PARTY_DETAILS,
        INDV_OR_ORG,
        SEX,
        BUSINESS_NAME,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged