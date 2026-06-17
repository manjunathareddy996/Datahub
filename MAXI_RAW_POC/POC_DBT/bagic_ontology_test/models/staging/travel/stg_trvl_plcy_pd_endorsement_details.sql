{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_ENDORSEMENT_DETAILS
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_ENDORSEMENT_DETAILS') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ENDORSEMENT_DETAILS,
        ENDORSEMENT_NUMBER,
        ENDORSEMENT_REVISED_SUM_INSURED,
        REMARKS,
        ENDORSEMENT_APPROVED_DATE,
        ENDORSEMENT_EFFECTIVE_DATE,
        TYPEOF_ENDORSEMENT,
        ENDORSEMENT_PREMIUM,
        ENDORSEMENT_SUM_INSURED,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged