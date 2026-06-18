{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DIGITALLABREPORTS
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_DIGITALLABREPORTS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        GENERAL_INFORMATION,
        COMMENTS,
        DIGITALLABREPORTS,
        ORGAN,
        "VALUES",
        TEST_COMPONENT,
        UNIT,
        REMARKS,
        VALUE,
        MIN_VAL,
        MAX_VAL,
        CODE,
        ALERT_INDICATOR,
        FIELD,

        -- Metadata
        INC_JOB_CREATED_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged