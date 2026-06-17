{{
    config(
        materialized='incremental',
        unique_key='hk_plcy_cd'
    )
}}

-- Hub Policy: One row per unique policy
-- Business Key: POLICY_NUMBER
-- Sources: MAXIMUS Health Policy/UWR

WITH source AS (
    SELECT DISTINCT
        POLICY_NUMBER,
        {{ hash('POLICY_NUMBER') }} AS hk_plcy_cd,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_trvl_plcy_policy_details') }}
    WHERE POLICY_NUMBER IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_plcy_cd FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT
        hk_plcy_cd,
        POLICY_NUMBER AS plcy_nbr,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_plcy_cd NOT IN (SELECT hk_plcy_cd FROM existing)
    {% endif %}
)

SELECT * FROM new_records
