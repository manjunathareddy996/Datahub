{{
    config(
        materialized='incremental',
        unique_key='hk_insrd_cd'
    )
}}

-- Hub Insured: One row per unique insured member
-- Business Key: MEMBER_CODE (from memberDetails within health policy)
-- Sources: MAXIMUS Health Policy (member_details)

WITH source AS (
    SELECT DISTINCT
        PARTY_CODE AS MEMBER_CODE,
        {{ hash('PARTY_CODE') }} AS hk_insrd_cd,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_trvl_plcy_pd_id_member_details') }}
    WHERE PARTY_CODE IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_insrd_cd FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT
        hk_insrd_cd,
        MEMBER_CODE AS insrd_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_insrd_cd NOT IN (SELECT hk_insrd_cd FROM existing)
    {% endif %}
)

SELECT * FROM new_records
