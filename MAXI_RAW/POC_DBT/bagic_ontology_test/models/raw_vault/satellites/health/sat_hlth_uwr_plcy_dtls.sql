{{
    config(
        materialized='incremental'
    )
}}

-- Health UWR Policy Details
-- Hub: hub_plcy | Attributes: 308
-- Source: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE
-- SCD Type 2: Insert new row on change (append strategy)

WITH source AS (
    SELECT
        src.*
    FROM {{ ref('stg_hlth_uwr_basic_detail_attribute') }} src
),

staged AS (
    SELECT
        {{ hash('FOREIGN_KEY') }} AS hk_plcy_cd,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm,
        {{ hash_diff(['FOREIGN_KEY']) }} AS rcrd_hsh_id,
        src.*
    FROM source src
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
