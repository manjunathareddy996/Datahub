{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Agent Details
-- Hub: hub_prtnr_role (agent-specific attributes)
-- Sources: MAXIMUS (simple property) + OPUS (BJAZ_INTERMEDIARY + BJAZ_INTERMEDIARY_HIST)
-- Per OPUS_MAPPING_FINAL: ALL 90 columns from intermediary tables land here
-- (includes GST, PAN, compliance — all agent-level)

WITH hub_role AS (
    SELECT 
        hk_prtnr_role_cd,
        prty_id,
        stake_cd
    FROM {{ ref('hub_prtnr_role') }}
    WHERE stake_cd = 'AGENT'
),

maximus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        sp.hk_prtnr_mstr_cd,
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,

        -- Agent fields from MAXIMUS (using correct column names from stg_partner_simple_property)
        NULL AS intermediary_id,
        NULL AS intermediary_name,
        sp.INTERMEDIARY_TYPE AS intermediary_type,
        sp.AGENT_CHANNEL AS business_channel,
        sp.LICENSE_NUMBER AS license_no,
        sp.EMPLOYEE_STATUS AS status,

        {{ hash_diff([
            'sp.INTERMEDIARY_TYPE', 'sp.AGENT_CHANNEL',
            'sp.LICENSE_NUMBER', 'sp.EMPLOYEE_STATUS'
        ]) }} AS rcrd_hsh_id

    FROM {{ ref('stg_partner_simple_property') }} sp
    INNER JOIN hub_role h 
        ON {{ hash(['sp.PARTY_CODE', "'AGENT'"]) }} = h.hk_prtnr_role_cd
    WHERE sp.AGENT_CHANNEL IS NOT NULL
       OR sp.EMPLOYEE_STATUS IS NOT NULL
       OR sp.INTERMEDIARY_TYPE IS NOT NULL
),

opus_intermediary AS (
    SELECT
        h.hk_prtnr_role_cd,
        oi.hk_prtnr_mstr_cd,
        oi.load_dt_tm AS ld_dt_tm,
        oi.record_source AS rcrd_src_nm,

        oi.INTERMEDIARY_ID AS intermediary_id,
        oi.INTERMEDIARY_NAME AS intermediary_name,
        oi.INTERMEDIARY_TYPE AS intermediary_type,
        oi.BUSINESS_CHANNEL AS business_channel,
        oi.LICENSE_NO AS license_no,
        oi.STATUS AS status,

        {{ hash_diff([
            'oi.INTERMEDIARY_ID', 'oi.INTERMEDIARY_TYPE', 'oi.BUSINESS_CHANNEL',
            'oi.LICENSE_NO', 'oi.STATUS'
        ]) }} AS rcrd_hsh_id

    FROM {{ ref('stg_opus_intermediary') }} oi
    INNER JOIN hub_role h 
        ON {{ hash(["oi.PART_ID", "'AGENT'"]) }} = h.hk_prtnr_role_cd
),

opus_intermediary_hist AS (
    SELECT
        h.hk_prtnr_role_cd,
        oih.hk_prtnr_mstr_cd,
        oih.load_dt_tm AS ld_dt_tm,
        oih.record_source AS rcrd_src_nm,

        oih.INTERMEDIARY_ID AS intermediary_id,
        oih.INTERMEDIARY_NAME AS intermediary_name,
        oih.INTERMEDIARY_TYPE AS intermediary_type,
        oih.BUSINESS_CHANNEL AS business_channel,
        oih.LICENSE_NO AS license_no,
        oih.STATUS AS status,

        {{ hash_diff([
            'oih.INTERMEDIARY_ID', 'oih.INTERMEDIARY_TYPE', 'oih.BUSINESS_CHANNEL',
            'oih.LICENSE_NO', 'oih.STATUS'
        ]) }} AS rcrd_hsh_id

    FROM {{ ref('stg_opus_intermediary_hist') }} oih
    INNER JOIN hub_role h 
        ON {{ hash(["oih.PART_ID", "'AGENT'"]) }} = h.hk_prtnr_role_cd
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_intermediary
    UNION ALL
    SELECT * FROM opus_intermediary_hist
)

{% if is_incremental() %}
, existing AS (
    SELECT hk_prtnr_role_cd, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_prtnr_role_cd ORDER BY ld_dt_tm DESC) = 1
)

SELECT c.*
FROM combined c
LEFT JOIN existing e ON c.hk_prtnr_role_cd = e.hk_prtnr_role_cd
WHERE e.hk_prtnr_role_cd IS NULL
   OR c.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM combined

{% endif %}
