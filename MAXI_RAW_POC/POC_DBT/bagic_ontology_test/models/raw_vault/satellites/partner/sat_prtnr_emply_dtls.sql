{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Employee Details
-- Hub: hub_prtnr_role (employee-specific attributes)
-- Sources: MAXIMUS (simple property) + OPUS (AZBJ_PARTNER_EXTN, BJAZ_AZBJ_PART_EXT_HIST)

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
        
        -- Employee identification
        sp.EMPLOYEE_CODE AS emp_id,
        sp.EMPLOYEE_STATUS AS employee_status,
        NULL AS web_user_id,
        
        {{ hash_diff(['sp.EMPLOYEE_CODE', 'sp.EMPLOYEE_STATUS']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_partner_simple_property') }} sp
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(sp.PARTY_CODE AS VARCHAR)
    WHERE sp.EMPLOYEE_CODE IS NOT NULL
),

opus_partner_extn AS (
    SELECT
        h.hk_prtnr_role_cd,
        ope.load_dt_tm AS ld_dt_tm,
        ope.record_source AS rcrd_src_nm,
        
        ope.EMP_ID AS emp_id,
        NULL AS web_user_id,
        NULL AS employee_status,
        
        {{ hash_diff(['ope.EMP_ID']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_partner_extn') }} ope
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(ope.PART_ID AS VARCHAR)
    WHERE ope.EMP_ID IS NOT NULL
),

opus_partner_extn_hist AS (
    SELECT
        h.hk_prtnr_role_cd,
        opeh.load_dt_tm AS ld_dt_tm,
        opeh.record_source AS rcrd_src_nm,
                
        -- OPUS-specific
        opeh.EMP_ID AS emp_id,
        opeh.WEB_USER_ID AS web_user_id,
        NULL AS employee_status,
        
        {{ hash_diff(['opeh.EMP_ID', 'opeh.WEB_USER_ID']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_partner_extn_hist') }} opeh
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(opeh.PART_ID AS VARCHAR)
    WHERE opeh.EMP_ID IS NOT NULL
       OR opeh.WEB_USER_ID IS NOT NULL
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_partner_extn
    UNION ALL
    SELECT * FROM opus_partner_extn_hist
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
