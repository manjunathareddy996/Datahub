{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_plcy_prtnr_hlth'
    )
}}

-- Link Health Policy to Partner (via proposer/member PARTY_CODE)
-- Connects hub_plcy to hub_prtnr_mstr

WITH hub_plcy AS (
    SELECT 
        hk_plcy_cd,
        plcy_nbr
    FROM {{ ref('hub_plcy') }}
),

hub_prtnr_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

source AS (
    SELECT DISTINCT
        pl.hk_plcy_cd,
        pm.hk_prtnr_mstr_cd,
        {{ hash(['pl.plcy_nbr', 'pm.prty_id']) }} AS hk_lnk_plcy_prtnr_hlth,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_trvl_plcy_policy_details') }} pd
    INNER JOIN {{ ref('stg_trvl_plcy_pd_proposer_details') }} prp ON pd.FOREIGN_KEY = prp.FOREIGN_KEY
    INNER JOIN hub_plcy pl ON pd.POLICY_NUMBER = pl.plcy_nbr
    INNER JOIN hub_prtnr_mstr pm ON prp.PARTY_CODE = pm.prty_id
    WHERE pd.POLICY_NUMBER IS NOT NULL
      AND prp.PARTY_CODE IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_plcy_prtnr_hlth FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_plcy_prtnr_hlth,
        hk_plcy_cd,
        hk_prtnr_mstr_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_lnk_plcy_prtnr_hlth NOT IN (SELECT hk_lnk_plcy_prtnr_hlth FROM existing)
    {% endif %}
)

SELECT * FROM new_records
