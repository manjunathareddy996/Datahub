{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        PARTY_ADDRESS,
        PARTY_START_DATE,
        PARTY_STATUS,
        PARENT_PARTY_CODE,
        PARTY_PROPERTY,
        REGISTRATION_DATE,
        TYPE_OF_PARTY,
        REGISTRATION_NO,
        NATIONALITY,
        PARTY_RELATION,
        CREATED_BY,
        RELATED_PARTY,
        PROPOSER_DETAILS,
        LAST_NAME,
        DOCUMENT_DETAIL,
        DATE_OF_BIRTH,
        TYPE_OF_ORGANIZATION,
        BUSINESS_NAME,
        MIDDLE_NAME,
        PARTY_LAST_MODIFICATION_DATE,
        TITLE,
        GENDER,
        PARTY_END_DATE,
        PARTY_CODE,
        OCCUPATION,
        FIRST_NAME,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged