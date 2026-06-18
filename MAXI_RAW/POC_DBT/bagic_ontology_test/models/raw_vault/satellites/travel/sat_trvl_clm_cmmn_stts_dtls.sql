{{
    config(
        materialized='incremental'
    )
}}

-- Travel Claim Common Status Details
-- Hub: hub_clm | Attributes: 95
-- Source: Staging claim attribute properties
-- SCD Type 2: Insert new row on change (append strategy)

WITH hub_clm AS (
    SELECT 
        hk_clm_cd,
        clm_nbr
    FROM {{ ref('hub_clm') }}
),

source AS (
    SELECT src.*
    FROM {{ ref('stg_trvl_clm_nonhlth_trv_clm_vw_data_cd_clm_attribute_proper_79') }} src
),

staged AS (
    SELECT
        -- Hub hash key from hub
        h.hk_clm_cd,

        -- Load metadata
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm,

        -- Hash diff for SCD2 change detection
        {{ hash_diff(['src.FOREIGN_KEY']) }} AS rcrd_hsh_id,

        -- All business columns from source
        src.*

    FROM source src
    INNER JOIN {{ ref('stg_trvl_clm_nonhlth_trv_clm_vw_data_clm_details') }} cd 
        ON src.FOREIGN_KEY = cd.FOREIGN_KEY
    INNER JOIN hub_clm h 
        ON cd.CLAIMNO = h.clm_nbr
)

{% if is_incremental() %}
, existing AS (
    SELECT hk_clm_cd, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_clm_cd ORDER BY ld_dt_tm DESC) = 1
)

SELECT s.*
FROM staged s
LEFT JOIN existing e ON s.hk_clm_cd = e.hk_clm_cd
WHERE e.hk_clm_cd IS NULL
   OR s.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM staged

{% endif %}
