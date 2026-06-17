{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW_2_1
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        ONLY_2D_ECO_RB,
        HYPERTENSION_RB,
        OTHER_DETAILS_1,
        CARDIOVASCULAR_RB,
        OTHERS_RB,
        APPLICABILITY_RB,
        THYROID_RB,
        OBESITY_RB,
        ASTHMA_RB,
        COL_REQUIRED_RB,
        ARTHRITIS_RB,
        DIABETES_RB,
        HYPERLIPIDAEMIA_RB,
        ECG_DEVIATION_RB,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged