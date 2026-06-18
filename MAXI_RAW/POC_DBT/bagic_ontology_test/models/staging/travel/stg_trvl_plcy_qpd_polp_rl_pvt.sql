{{
    config(
        materialized='view'
    )
}}

-- Staging: NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW_2_1
-- Source: raw_travel_policy

WITH source AS (
    SELECT *
    FROM {{ source('raw_travel_policy', 'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW_2_1') }}
),

staged AS (
    SELECT
        *,
        CURRENT_TIMESTAMP() AS load_dt_tm,
        'MAXIMUS' AS record_source
    FROM source
)

SELECT * FROM staged