{{
    config(
        materialized='incremental',
        unique_key='hk_prtnr_mstr_cd'
    )
}}

-- Hub Partner Master: One row per unique partner (person/entity)
-- Business Key: PARTY_CODE
-- Grain: One partner = one row regardless of roles

WITH maximus_source AS (
    SELECT
        hk_prtnr_mstr_cd,
        CAST(PARTY_CODE AS VARCHAR) AS prty_id,
        load_dt_tm,
        record_source
    FROM {{ ref('stg_partner_detail') }}
),

opus_source AS (
    SELECT
        hk_prtnr_mstr_cd,
        CAST(PART_ID AS VARCHAR) AS prty_id,
        load_dt_tm,
        record_source
    FROM {{ ref('stg_opus_partner') }}
),

source AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_source
),

{% if is_incremental() %}
existing AS (
    SELECT hk_prtnr_mstr_cd
    FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_prtnr_mstr_cd,
        CAST(prty_id AS VARCHAR) AS prty_id,
        load_dt_tm AS ld_dt_tm,
        record_source AS rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_prtnr_mstr_cd NOT IN (SELECT hk_prtnr_mstr_cd FROM existing)
    {% endif %}
)

SELECT * FROM new_records
