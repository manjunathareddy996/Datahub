{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_plcy_prpsr'
    )
}}

-- Link Health Policy to Proposer
-- Connects hub_plcy to hub_prpsr (1:1 — one policy has one proposer)

WITH hub_plcy AS (
    SELECT 
        hk_plcy_cd,
        plcy_nbr
    FROM {{ ref('hub_plcy') }}
),

hub_prpsr AS (
    SELECT 
        hk_prpsr_cd,
        prpsr_cd
    FROM {{ ref('hub_prpsr') }}
),

source AS (
    SELECT DISTINCT
        pl.hk_plcy_cd,
        pr.hk_prpsr_cd,
        {{ hash(['pl.plcy_nbr', 'pr.prpsr_cd']) }} AS hk_lnk_plcy_prpsr,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_trvl_plcy_policy_details') }} pd
    INNER JOIN {{ ref('stg_trvl_plcy_pd_proposer_details') }} prp ON pd.FOREIGN_KEY = prp.FOREIGN_KEY
    INNER JOIN hub_plcy pl ON pd.POLICY_NUMBER = pl.plcy_nbr
    INNER JOIN hub_prpsr pr ON prp.PARTY_CODE = pr.prpsr_cd
    WHERE pd.POLICY_NUMBER IS NOT NULL
      AND prp.PARTY_CODE IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_plcy_prpsr FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_plcy_prpsr,
        hk_plcy_cd,
        hk_prpsr_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_lnk_plcy_prpsr NOT IN (SELECT hk_lnk_plcy_prpsr FROM existing)
    {% endif %}
)

SELECT * FROM new_records
