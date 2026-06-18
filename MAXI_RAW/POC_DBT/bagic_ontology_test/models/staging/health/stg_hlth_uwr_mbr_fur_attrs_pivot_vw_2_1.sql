{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBERS_FOLLOW_UP_REPORT_ATTRIBUTES_PIVOT_VW_2_1
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_FOLLOW_UP_REPORT_ATTRIBUTES_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ENDORSEMENT_NUMBER_CLAIM_NUMBER,
        TIME,
        STATUS,
        EFFECTIVE_DATE,
        USER_CODE,
        DATE,
        SUBSTATUS,
        REMARKS,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged