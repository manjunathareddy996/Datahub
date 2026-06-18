{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_plcy_insrd'
    )
}}

-- Link Health Policy to Insured
-- Connects hub_plcy to hub_insrd (1:N — one policy has many insured members)

WITH hub_plcy AS (
    SELECT 
        hk_plcy_cd,
        plcy_nbr
    FROM {{ ref('hub_plcy') }}
),

hub_insrd AS (
    SELECT 
        hk_insrd_cd,
        insrd_cd
    FROM {{ ref('hub_insrd') }}
),

source AS (
    SELECT DISTINCT
        pl.hk_plcy_cd,
        ins.hk_insrd_cd,
        {{ hash(['pl.plcy_nbr', 'ins.insrd_cd']) }} AS hk_lnk_plcy_insrd,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_trvl_plcy_policy_details') }} pd
    INNER JOIN {{ ref('stg_trvl_plcy_pd_insured_details') }} ins_stg ON pd.FOREIGN_KEY = ins_stg.FOREIGN_KEY
    INNER JOIN {{ ref('stg_trvl_plcy_pd_id_member_details') }} mem ON ins_stg.FOREIGN_KEY = mem.FOREIGN_KEY
    INNER JOIN hub_plcy pl ON pd.POLICY_NUMBER = pl.plcy_nbr
    INNER JOIN hub_insrd ins ON mem.PARTY_CODE = ins.insrd_cd
    WHERE pd.POLICY_NUMBER IS NOT NULL
      AND mem.PARTY_CODE IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_plcy_insrd FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_plcy_insrd,
        hk_plcy_cd,
        hk_insrd_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_lnk_plcy_insrd NOT IN (SELECT hk_lnk_plcy_insrd FROM existing)
    {% endif %}
)

SELECT * FROM new_records
