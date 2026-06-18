{{
    config(
        materialized='incremental'
    )
}}

-- Health UWR Payment Details
-- Hub: hub_plcy | Attributes: 55
-- Source: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO
-- SCD Type 2: Insert new row on change (append strategy)

WITH source AS (
    SELECT
        src.*
    FROM {{ ref('stg_hlth_uwr_payment_info') }} src
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
