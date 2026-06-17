{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_prtnr_rltn'
    )
}}

-- Link Partner Relation (Self-referencing)
-- Connects hub_prtnr_mstr to hub_prtnr_mstr (partner related to partner)
-- Sources: MAXIMUS (related_party table) — OPUS has parent/child via AZBJ_PARTNER_EXTN.PARENT_ID

WITH hub_prtnr_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
    LIMIT 1000
),

maximus_source AS (
    SELECT
        pm_from.hk_prtnr_mstr_cd AS hk_prtnr_mstr_from,
        pm_to.hk_prtnr_mstr_cd AS hk_prtnr_mstr_to,
        {{ hash(['pm_from.prty_id', 'pm_to.prty_id']) }} AS hk_lnk_prtnr_rltn,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_partner_detail') }} pd
    INNER JOIN {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_RELATED_PARTY') }} rp
        ON pd.FOREIGN_KEY = rp.FOREIGN_KEY
    INNER JOIN hub_prtnr_mstr pm_from ON CAST(pd.PARTY_CODE AS VARCHAR) = pm_from.prty_id
    INNER JOIN hub_prtnr_mstr pm_to ON CAST(rp.ROOT_HASH AS VARCHAR) = pm_to.prty_id
    WHERE pd.PARTY_CODE IS NOT NULL
      AND rp.ROOT_HASH IS NOT NULL
),

-- OPUS: parent-child relationship from AZBJ_PARTNER_EXTN.PARENT_ID
opus_source AS (
    SELECT
        pm_from.hk_prtnr_mstr_cd AS hk_prtnr_mstr_from,
        pm_to.hk_prtnr_mstr_cd AS hk_prtnr_mstr_to,
        {{ hash(['pm_from.prty_id', 'pm_to.prty_id']) }} AS hk_lnk_prtnr_rltn,
        ope.load_dt_tm AS ld_dt_tm,
        ope.record_source AS rcrd_src_nm
    FROM {{ ref('stg_opus_partner_extn') }} ope
    INNER JOIN hub_prtnr_mstr pm_from ON CAST(ope.PART_ID AS VARCHAR) = pm_from.prty_id
    INNER JOIN hub_prtnr_mstr pm_to ON CAST(ope.PARENT_ID AS VARCHAR) = pm_to.prty_id
    WHERE ope.PARENT_ID IS NOT NULL
      AND CAST(ope.PARENT_ID AS VARCHAR) != ''
),

source AS (
    SELECT hk_lnk_prtnr_rltn, hk_prtnr_mstr_from, hk_prtnr_mstr_to, ld_dt_tm, rcrd_src_nm FROM maximus_source
    UNION ALL
    SELECT hk_lnk_prtnr_rltn, hk_prtnr_mstr_from, hk_prtnr_mstr_to, ld_dt_tm, rcrd_src_nm FROM opus_source
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_prtnr_rltn
    FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_prtnr_rltn,
        hk_prtnr_mstr_from,
        hk_prtnr_mstr_to,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_lnk_prtnr_rltn NOT IN (SELECT hk_lnk_prtnr_rltn FROM existing)
    {% endif %}
)

SELECT * FROM new_records
