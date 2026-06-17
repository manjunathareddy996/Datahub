{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_clm_plcy'
    )
}}

-- Link Health Claim to Policy
-- Connects hub_clm to hub_plcy (N:1 — many claims per policy)

WITH hub_clm AS (
    SELECT 
        hk_clm_cd,
        clm_nbr
    FROM {{ ref('hub_clm') }}
),

hub_plcy AS (
    SELECT 
        hk_plcy_cd,
        plcy_nbr
    FROM {{ ref('hub_plcy') }}
),

source AS (
    SELECT DISTINCT
        c.hk_clm_cd,
        p.hk_plcy_cd,
        {{ hash(['c.clm_nbr', 'p.plcy_nbr']) }} AS hk_lnk_clm_plcy,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_trvl_clm_nonhlth_trv_clm_vw_data_clm_details') }} s
    INNER JOIN hub_clm c ON s.CLAIMNO = c.clm_nbr
    INNER JOIN hub_plcy p ON s.POLICYNO = p.plcy_nbr
    WHERE s.CLAIMNO IS NOT NULL
      AND s.POLICYNO IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_clm_plcy FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_clm_plcy,
        hk_clm_cd,
        hk_plcy_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_lnk_clm_plcy NOT IN (SELECT hk_lnk_clm_plcy FROM existing)
    {% endif %}
)

SELECT * FROM new_records
