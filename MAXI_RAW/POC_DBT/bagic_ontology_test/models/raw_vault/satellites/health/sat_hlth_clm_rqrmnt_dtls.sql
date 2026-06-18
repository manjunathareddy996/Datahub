{{
    config(
        materialized='incremental'
    )
}}

-- Health Claim Requirement Details
-- Hub: hub_clm | Attributes: 21
-- Source: MAXI_HLTH_CLM_VW_DATA
-- SCD Type 2: Insert new row on change (append strategy)

WITH source AS (
    SELECT
        src.*
    FROM {{ ref('stg_hlth_clm_maxi_hlth_clm_vw_data') }} src
),

staged AS (
    SELECT
        {{ hash('FOREIGN_KEY') }} AS hk_clm_cd,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm,
        {{ hash_diff(['FOREIGN_KEY']) }} AS rcrd_hsh_id,
        src.*
    FROM source src
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
