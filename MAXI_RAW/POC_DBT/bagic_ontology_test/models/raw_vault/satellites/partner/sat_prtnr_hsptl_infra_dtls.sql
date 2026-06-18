{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Hospital Infrastructure Details
-- Hub: hub_prtnr_role (HOSPITAL role)
-- Sources: MAXIMUS (simple property) + OPUS (BJAZ_HM_HOSPITAL_MASTER)

WITH hub_role AS (
    SELECT 
        hk_prtnr_role_cd,
        prty_id,
        stake_cd
    FROM {{ ref('hub_prtnr_role') }}
),

maximus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,
        
        -- Hospital fields from MAXIMUS
        CAST(sp.HOSPITAL_NAME AS VARCHAR) AS hospital_name,
        CAST(sp.HOSPITAL_SPECIALITY AS VARCHAR) AS hospital_type,
        CAST(sp.PROVIDER_CATEGORY AS VARCHAR) AS network_type,
        CAST(sp.ONLINE_HOSPITAL_REFERENCE_NUMBER AS VARCHAR) AS hosid,
        
        {{ hash_diff(['CAST(sp.HOSPITAL_NAME AS VARCHAR)', 'CAST(sp.HOSPITAL_SPECIALITY AS VARCHAR)', 'CAST(sp.PROVIDER_CATEGORY AS VARCHAR)', 'CAST(sp.ONLINE_HOSPITAL_REFERENCE_NUMBER AS VARCHAR)']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_partner_simple_property') }} sp
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(sp.PARTY_CODE AS VARCHAR)
    WHERE sp.HOSPITAL_NAME IS NOT NULL
),

opus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        ohm.load_dt_tm AS ld_dt_tm,
        ohm.record_source AS rcrd_src_nm,
        
        CAST(ohm.HOSPITAL_NAME AS VARCHAR) AS hospital_name,
        CAST(ohm.HOSP_TYPE AS VARCHAR) AS hospital_type,
        CAST(ohm.NETWORK_TYPE AS VARCHAR) AS network_type,
        CAST(ohm.HOSID AS VARCHAR) AS hosid,
        
        {{ hash_diff(['CAST(ohm.HOSPITAL_NAME AS VARCHAR)', 'CAST(ohm.HOSP_TYPE AS VARCHAR)', 'CAST(ohm.NETWORK_TYPE AS VARCHAR)', 'CAST(ohm.HOSID AS VARCHAR)']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_hospital_master') }} ohm
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(ohm.PART_ID AS VARCHAR)
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_source
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
