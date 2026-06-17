{{
    config(
        materialized='incremental',
        unique_key='hk_prtnr_role_cd'
    )
}}

-- Hub Partner Role: One row per partner+role combination
-- Business Key: PARTY_CODE + STAKE_CODE (composite)
-- Grain: One partner playing one role = one row
-- Sources: MAXIMUS (multi-set pivot) + OPUS (BJAZ_CLM_SUPP_EXTN type, BJAZ_INTERMEDIARY)

WITH maximus_source AS (
    SELECT
        CAST(PARTY_CODE AS VARCHAR) AS prty_id,
        STAKE_CODE AS stake_cd,
        hk_prtnr_role_cd,
        load_dt_tm AS ld_dt_tm,
        record_source AS rcrd_src_nm
    FROM {{ ref('stg_partner_multiset_property') }}
),

-- OPUS: Intermediaries are AGENT role
opus_intermediary AS (
    SELECT
        CAST(PART_ID AS VARCHAR) AS prty_id,
        'AGENT' AS stake_cd,
        {{ hash(["PART_ID", "'AGENT'"]) }} AS hk_prtnr_role_cd,
        load_dt_tm AS ld_dt_tm,
        record_source AS rcrd_src_nm
    FROM {{ ref('stg_opus_intermediary') }}
),

-- OPUS: Suppliers have role based on SUPP_TYPE (SURVEYOR, DEALER, LAWYER, etc.)
opus_supplier AS (
    SELECT
        CAST(PART_ID AS VARCHAR) AS prty_id,
        SUPP_TYPE AS stake_cd,
        {{ hash(['PART_ID', 'SUPP_TYPE']) }} AS hk_prtnr_role_cd,
        load_dt_tm AS ld_dt_tm,
        record_source AS rcrd_src_nm
    FROM {{ ref('stg_opus_clm_supplier') }}
    WHERE SUPP_TYPE IS NOT NULL
      AND SUPP_TYPE != ''
),

-- OPUS: Hospital master = HOSPITAL role
opus_hospital AS (
    SELECT
        CAST(PART_ID AS VARCHAR) AS prty_id,
        'HOSPITAL' AS stake_cd,
        {{ hash(["PART_ID", "'HOSPITAL'"]) }} AS hk_prtnr_role_cd,
        load_dt_tm AS ld_dt_tm,
        record_source AS rcrd_src_nm
    FROM {{ ref('stg_opus_hospital_master') }}
),

source AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_intermediary
    UNION ALL
    SELECT * FROM opus_supplier
    UNION ALL
    SELECT * FROM opus_hospital
),

{% if is_incremental() %}
existing AS (
    SELECT hk_prtnr_role_cd
    FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_prtnr_role_cd,
        prty_id,
        stake_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_prtnr_role_cd NOT IN (SELECT hk_prtnr_role_cd FROM existing)
    {% endif %}
)

SELECT * FROM new_records
