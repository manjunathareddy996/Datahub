{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Bank Financial Details
-- Hub: hub_prtnr_role (bank details can vary by role)
-- Sources: MAXIMUS (simple property) + OPUS (AZBJ_PARTNER_EXTN + BJAZ_AZBJ_PART_EXT_HIST)
-- Per OPUS_MAPPING_FINAL: 13 OPUS columns land here (bank/financial from partner extn only)
-- Note: Supplier bank fields (SUPP_BANK_NAME etc) now go to sat_prtnr_srvyr_invstgtr_dtls

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
        msp.hk_prtnr_mstr_cd,
        msp.load_dt_tm AS ld_dt_tm,
        msp.record_source AS rcrd_src_nm,
        
        -- Columns in hash_diff (from multiset property)
        msp.BANK_ACCOUNT_NUMBER,
        msp.ACCOUNT_TYPE AS BANK_ACCOUNT_TYPE,
        msp.IFSC AS IFSC_CODE,
        msp.MICR AS MICR_CODE,
        
        {{ hash_diff(['msp.BANK_ACCOUNT_NUMBER', 'msp.ACCOUNT_TYPE', 'msp.IFSC', 'msp.MICR']) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_partner_multiset_property') }} msp
    INNER JOIN hub_role h 
        ON {{ hash(['msp.PARTY_CODE', 'msp.STAKE_CODE']) }} = h.hk_prtnr_role_cd
    WHERE msp.BANK_ACCOUNT_NUMBER IS NOT NULL
       OR msp.IFSC IS NOT NULL
       OR msp.BANK_NAME IS NOT NULL
),

opus_partner_extn AS (
    SELECT
        h.hk_prtnr_role_cd,
        ope.hk_prtnr_mstr_cd,
        ope.load_dt_tm AS ld_dt_tm,
        ope.record_source AS rcrd_src_nm,
        
        -- Columns in hash_diff (map OPUS to MAXIMUS naming)
        ope.ACCOUNT_NO AS BANK_ACCOUNT_NUMBER,
        ope.ACC_TYPE AS BANK_ACCOUNT_TYPE,
        ope.IFSC_CODE,
        ope.MICR_CODE,
        
        {{ hash_diff(['ope.ACCOUNT_NO', 'ope.ACC_TYPE', 'ope.IFSC_CODE', 'ope.MICR_CODE']) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_opus_partner_extn') }} ope
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(ope.PART_ID AS VARCHAR)
    WHERE ope.ACCOUNT_NO IS NOT NULL
       OR ope.IFSC_CODE IS NOT NULL
       OR ope.PAIDUP_CAPITAL IS NOT NULL
),

opus_partner_extn_hist AS (
    SELECT
        h.hk_prtnr_role_cd,
        opeh.hk_prtnr_mstr_cd,
        opeh.load_dt_tm AS ld_dt_tm,
        opeh.record_source AS rcrd_src_nm,
        
        -- Columns in hash_diff (map OPUS to MAXIMUS naming)
        opeh.ACCOUNT_NO AS BANK_ACCOUNT_NUMBER,
        opeh.ACC_TYPE AS BANK_ACCOUNT_TYPE,
        opeh.IFSC_CODE,
        opeh.MICR_CODE,
        
        {{ hash_diff(['opeh.ACCOUNT_NO', 'opeh.ACC_TYPE', 'opeh.IFSC_CODE', 'opeh.MICR_CODE']) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_opus_partner_extn_hist') }} opeh
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(opeh.PART_ID AS VARCHAR)
    WHERE opeh.ACCOUNT_NO IS NOT NULL
       OR opeh.IFSC_CODE IS NOT NULL
       OR opeh.PAIDUP_CAPITAL IS NOT NULL
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
