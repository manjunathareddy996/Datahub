{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        TYPE_OF_ORGANIZATION,
        PARTY_CODE,
        PARTY_END_DATE,
        MIDDLE_NAME,
        PARTY_STATUS,
        TYPE_OF_PARTY,
        FIRST_NAME,
        MEMBER_DETAILS,
        DOCUMENT_DETAIL,
        PARTY_START_DATE,
        PARTY_LAST_MODIFICATION_DATE,
        GENDER,
        DATE_OF_BIRTH,
        REGISTRATION_NO,
        TITLE,
        NATIONALITY,
        RELATED_PARTY,
        LAST_NAME,
        CREATED_BY,
        PARTY_ADDRESS,
        BUSINESS_NAME,
        OCCUPATION,
        PARENT_PARTY_CODE,
        PARTY_RELATION,
        REGISTRATION_DATE,
        PARTY_PROPERTY,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged