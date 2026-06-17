{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_prtnr_dcmnt'
    )
}}

-- Link Partner to Document
-- Connects hub_prtnr_mstr to hub_dcmnt
-- Sources: MAXIMUS (document_detail via party_detail) — OPUS does not have a document table

WITH hub_prtnr_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

source AS (
    SELECT
        pm.hk_prtnr_mstr_cd,
        {{ hash('dd.ROOT_HASH') }} AS hk_dcmnt_cd,
        {{ hash(['pm.prty_id', 'dd.ROOT_HASH']) }} AS hk_lnk_prtnr_dcmnt,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        'MAXIMUS' AS rcrd_src_nm
    FROM {{ ref('stg_partner_detail') }} pd
    INNER JOIN {{ source('raw_maximus', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_DOCUMENT_DETAIL') }} dd
        ON pd.FOREIGN_KEY = dd.FOREIGN_KEY
    INNER JOIN hub_prtnr_mstr pm ON pd.PARTY_CODE = pm.prty_id
    WHERE pd.PARTY_CODE IS NOT NULL
      AND dd.ROOT_HASH IS NOT NULL
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_prtnr_dcmnt
    FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_prtnr_dcmnt,
        hk_prtnr_mstr_cd,
        hk_dcmnt_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_lnk_prtnr_dcmnt NOT IN (SELECT hk_lnk_prtnr_dcmnt FROM existing)
    {% endif %}
)

SELECT * FROM new_records
