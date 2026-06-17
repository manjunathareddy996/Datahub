{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_mstr_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner KYC Identification Details
-- Hub: hub_prtnr_mstr (KYC is person-level, role-independent)
-- Sources: MAXIMUS (simple property) + OPUS (AZBJ_PARTNER_EXTN, BJAZ_CP_PART_HIST, CLM_INTERESTED_PARTIES)
-- Per OPUS_MAPPING_FINAL: Only 5 OPUS columns land here

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

maximus_source AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,
        
        sp.PAN_NUMBER,
        sp.AADHAAR_NUMBER,
        sp.PASSPORT_NUMBER,
        sp.CKYC_NUMBER,
        
        -- OPUS-only
        NULL AS EXISTING_CUST,
        NULL AS EXISTING_POLICY_PID,
        NULL AS EVIDENCE,
        NULL AS EVID_TYPE,
        NULL AS INS_OBJ_UID,
        
        {{ hash_diff(['sp.PAN_NUMBER', 'sp.AADHAAR_NUMBER', 'sp.PASSPORT_NUMBER', 'sp.CKYC_NUMBER']) }} AS rcrd_hsh_id
    FROM hub_mstr h
    INNER JOIN {{ ref('stg_partner_simple_property') }} sp
        ON h.prty_id = sp.PARTY_CODE
    WHERE sp.PAN_NUMBER IS NOT NULL
       OR sp.AADHAAR_NUMBER IS NOT NULL
       OR sp.PASSPORT_NUMBER IS NOT NULL
       OR sp.CKYC_NUMBER IS NOT NULL
),

-- OPUS: EXISTING_CUST, EXISTING_POLICY_PID from partner extn
opus_partner_extn AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        ope.load_dt_tm AS ld_dt_tm,
        ope.record_source AS rcrd_src_nm,
        
        NULL AS PAN_NUMBER,
        NULL AS AADHAAR_NUMBER,
        NULL AS PASSPORT_NUMBER,
        NULL AS CKYC_NUMBER,
        
        ope.EXISTING_CUST,
        ope.EXISTING_POLICY_PID,
        NULL AS EVIDENCE,
        NULL AS EVID_TYPE,
        NULL AS INS_OBJ_UID,
        
        {{ hash_diff(['ope.EXISTING_CUST', 'ope.EXISTING_POLICY_PID']) }} AS rcrd_hsh_id
    FROM hub_mstr h
    INNER JOIN {{ ref('stg_opus_partner_extn') }} ope
        ON h.prty_id = CAST(ope.PART_ID AS VARCHAR)
    WHERE ope.EXISTING_CUST IS NOT NULL
       OR ope.EXISTING_POLICY_PID IS NOT NULL
),

-- OPUS: EVIDENCE, EVID_TYPE from partner history
opus_partner_hist AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        oph.load_dt_tm AS ld_dt_tm,
        oph.record_source AS rcrd_src_nm,
        
        NULL AS PAN_NUMBER,
        NULL AS AADHAAR_NUMBER,
        NULL AS PASSPORT_NUMBER,
        NULL AS CKYC_NUMBER,
        
        NULL AS EXISTING_CUST,
        NULL AS EXISTING_POLICY_PID,
        oph.EVIDENCE,
        oph.EVID_TYPE,
        NULL AS INS_OBJ_UID,
        
        {{ hash_diff(['oph.EVIDENCE', 'oph.EVID_TYPE']) }} AS rcrd_hsh_id
    FROM hub_mstr h
    INNER JOIN {{ ref('stg_opus_partner_hist') }} oph
        ON h.prty_id = CAST(oph.PART_ID AS VARCHAR)
    WHERE oph.EVIDENCE IS NOT NULL
       OR oph.EVID_TYPE IS NOT NULL
),

-- OPUS: INS_OBJ_UID from claim interested parties
opus_clm_ip AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        ocip.load_dt_tm AS ld_dt_tm,
        ocip.record_source AS rcrd_src_nm,
        
        NULL AS PAN_NUMBER,
        NULL AS AADHAAR_NUMBER,
        NULL AS PASSPORT_NUMBER,
        NULL AS CKYC_NUMBER,
        
        NULL AS EXISTING_CUST,
        NULL AS EXISTING_POLICY_PID,
        NULL AS EVIDENCE,
        NULL AS EVID_TYPE,
        ocip.INS_OBJ_UID,
        
        {{ hash_diff(['ocip.INS_OBJ_UID']) }} AS rcrd_hsh_id
    FROM hub_mstr h
    INNER JOIN {{ ref('stg_opus_clm_interested_parties') }} ocip
        ON h.prty_id = CAST(ocip.PART_ID AS VARCHAR)
    WHERE ocip.INS_OBJ_UID IS NOT NULL
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_partner_extn
    UNION ALL
    SELECT * FROM opus_partner_hist
    UNION ALL
    SELECT * FROM opus_clm_ip
)

{% if is_incremental() %}
, existing AS (
    SELECT hk_prtnr_mstr_cd, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_prtnr_mstr_cd ORDER BY ld_dt_tm DESC) = 1
)

SELECT c.*
FROM combined c
LEFT JOIN existing e ON c.hk_prtnr_mstr_cd = e.hk_prtnr_mstr_cd
WHERE e.hk_prtnr_mstr_cd IS NULL
   OR c.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM combined

{% endif %}
