{{
    config(
        materialized='incremental',
        unique_key='hk_clm_cd'
    )
}}

-- Hub Claim: One row per unique claim
-- Business Key: CLAIM_NUMBER (from health_claim.json → CLAIMNO / claim_details.POLICYNO context)
-- Sources: MAXIMUS Health Claim

WITH source AS (
    SELECT DISTINCT
        CLAIMNO,
        {{ hash('CLAIMNO') }} AS hk_clm_cd,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_trvl_clm_nonhlth_trv_clm_vw_data_clm_details') }}
    WHERE CLAIMNO IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_clm_cd FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT
        hk_clm_cd,
        CLAIMNO AS clm_nbr,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_clm_cd NOT IN (SELECT hk_clm_cd FROM existing)
    {% endif %}
)

SELECT * FROM new_records
