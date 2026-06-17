{{
    config(
        materialized='incremental'
    )
}}

-- Travel UWR Risk Itinerary Details
-- Hub: hub_plcy | Attributes: 60
-- Source: NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1
-- SCD Type 2: Insert new row on change (append strategy)

WITH hub_plcy AS (
    SELECT 
        hk_plcy_cd,
        plcy_nbr
    FROM {{ ref('hub_plcy') }}
),

source AS (
    SELECT src.*
    FROM {{ ref('stg_trvl_plcy_pd_polp_sp_pvt') }} src
),

staged AS (
    SELECT
        -- Hub hash key from hub
        h.hk_plcy_cd,

        -- Load metadata
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm,

        -- Hash diff for SCD2 change detection
        {{ hash_diff(['src.FOREIGN_KEY']) }} AS rcrd_hsh_id,

        -- All business columns from source
        src.*

    FROM source src
    INNER JOIN {{ ref('stg_trvl_plcy_policy_details') }} pd 
        ON src.FOREIGN_KEY = pd.FOREIGN_KEY
    INNER JOIN hub_plcy h 
        ON pd.POLICY_NUMBER = h.plcy_nbr
)

{% if is_incremental() %}
, existing AS (
    SELECT hk_plcy_cd, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_plcy_cd ORDER BY ld_dt_tm DESC) = 1
)

SELECT s.*
FROM staged s
LEFT JOIN existing e ON s.hk_plcy_cd = e.hk_plcy_cd
WHERE e.hk_plcy_cd IS NULL
   OR s.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM staged

{% endif %}
