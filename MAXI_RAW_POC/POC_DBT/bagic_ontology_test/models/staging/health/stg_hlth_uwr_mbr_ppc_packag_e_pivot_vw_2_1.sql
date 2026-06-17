{{
    config(
        materialized='view'
    )
}}

-- Staging: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAG_E_PIVOT_VW_2_1
-- Source: raw_health_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_health_policy', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAG_E_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        -- Keys
        FOREIGN_KEY,

        -- Business columns
        HERIZON_CARE_PLAN_3,
        NIDAAN_SWASTHYA_1,
        WOMEN_SPECIFIC_CRITICAL_ILLNESS_2,
        CHLP_2,
        GLOBALSET,
        CRITICARE,
        VHC,
        HERIZON_CARE_PLAN_1,
        CHLP_1,
        INFINITY_1,
        CCP_1,
        CCP_2,
        INFINITY_2,
        SET1,
        HERIZON_CARE_PLAN_2,
        PORT_SET,
        CRITICARE_1,
        WOMEN_SPECIFIC_CRITICAL_ILLNESS_1,

        -- Metadata
        INC_JOB_CREATED_AT,
        REC_REFRESH_AT,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source

    FROM source src
)

SELECT * FROM staged