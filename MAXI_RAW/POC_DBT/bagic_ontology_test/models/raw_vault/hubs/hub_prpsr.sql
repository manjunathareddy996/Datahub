{{
    config(
        materialized='incremental',
        unique_key='hk_prpsr_cd'
    )
}}

-- Hub Proposer: One row per unique proposer
-- Business Key: PROPOSER_CODE (from proposer_details within health policy)
-- Sources: MAXIMUS Health Policy (proposer_details)

WITH source AS (
    SELECT DISTINCT
        PARTY_CODE AS PROPOSER_CODE,
        {{ hash('PARTY_CODE') }} AS hk_prpsr_cd,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_trvl_plcy_pd_proposer_details') }}
    WHERE PARTY_CODE IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_prpsr_cd FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT
        hk_prpsr_cd,
        PROPOSER_CODE AS prpsr_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_prpsr_cd NOT IN (SELECT hk_prpsr_cd FROM existing)
    {% endif %}
)

SELECT * FROM new_records
