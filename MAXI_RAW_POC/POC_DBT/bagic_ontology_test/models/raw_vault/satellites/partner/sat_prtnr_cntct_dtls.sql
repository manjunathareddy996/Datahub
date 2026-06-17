{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Contact Details
-- Hub: hub_prtnr_role (contact can vary by role)
-- Sources: MAXIMUS (address) + OPUS (AZBJ_PARTNER_EXTN, BJAZ_AZBJ_PART_EXT_HIST, BJAZ_CP_PART_HIST)
-- Per OPUS_MAPPING_FINAL: 13 OPUS columns land here (only contact-specific from partner extn)

WITH hub_role AS (
    SELECT 
        hk_prtnr_role_cd,
        prty_id,
        stake_cd
    FROM {{ ref('hub_prtnr_role') }}
),

multi_set AS (
    SELECT
        PARTY_CODE,
        STAKE_CODE,
        hk_prtnr_role_cd,
        MOBILE_NO,
        EMAIL_ID,
        load_dt_tm,
        record_source
    FROM {{ ref('stg_partner_multiset_property') }}
),

maximus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        msp.load_dt_tm AS ld_dt_tm,
        msp.record_source AS rcrd_src_nm,
        
        -- Contact columns
        msp.EMAIL_ID,
        msp.MOBILE_NO,
        CONCAT_WS(', ', sp.PHONE_NO_1, sp.PHONE_NO_2, sp.ALTERNATE_MOB_NUMBER, sp.LANDLINE_NUMBER) AS ALT_MOBILE_NO,
        sp.LANDLINE_NO,
        sp.STD_CODE,
        NULL AS ALT_EMAIL_ID,
        NULL AS PREFERRED_CONTACT_OPT,
        NULL AS FAX,
        
        {{ hash_diff(['msp.EMAIL_ID', 'msp.MOBILE_NO', 'sp.LANDLINE_NO', 'sp.STD_CODE']) }} AS rcrd_hsh_id
        
    FROM multi_set msp
    INNER JOIN hub_role h 
        ON h.hk_prtnr_role_cd = msp.hk_prtnr_role_cd
    LEFT JOIN {{ ref('stg_partner_simple_property') }} sp 
        ON msp.PARTY_CODE = sp.PARTY_CODE
    WHERE msp.EMAIL_ID IS NOT NULL
       OR msp.MOBILE_NO IS NOT NULL
       OR sp.LANDLINE_NO IS NOT NULL
),

opus_partner_extn AS (
    SELECT
        h.hk_prtnr_role_cd,
        ope.load_dt_tm AS ld_dt_tm,
        ope.record_source AS rcrd_src_nm,
        
        -- Contact columns
        ope.EMAIL_2 AS EMAIL_ID,
        ope.TELEPHONE3 AS MOBILE_NO,
        ope.ALT_MOBILE_NO,
        NULL AS LANDLINE_NO,
        NULL AS STD_CODE,
        ope.ALT_EMAIL_ID,
        ope.PREFERRED_CONTACT_OPT,
        NULL AS FAX,
        
        {{ hash_diff([
            'ope.TELEPHONE3', 'ope.EMAIL_2', 'ope.ALT_MOBILE_NO', 'ope.ALT_EMAIL_ID',
            'ope.PREFERRED_CONTACT_OPT'
        ]) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_opus_partner_extn') }} ope
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(ope.PART_ID AS VARCHAR)
    WHERE ope.TELEPHONE3 IS NOT NULL
       OR ope.EMAIL_2 IS NOT NULL
       OR ope.ALT_MOBILE_NO IS NOT NULL
),

opus_partner_extn_hist AS (
    SELECT
        h.hk_prtnr_role_cd,
        opeh.load_dt_tm AS ld_dt_tm,
        opeh.record_source AS rcrd_src_nm,
        
        -- Contact columns
        opeh.EMAIL_2 AS EMAIL_ID,
        opeh.TELEPHONE3 AS MOBILE_NO,
        NULL AS ALT_MOBILE_NO,
        NULL AS LANDLINE_NO,
        NULL AS STD_CODE,
        NULL AS ALT_EMAIL_ID,
        NULL AS PREFERRED_CONTACT_OPT,
        NULL AS FAX,
        
        {{ hash_diff(['opeh.TELEPHONE3', 'opeh.EMAIL_2']) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_opus_partner_extn_hist') }} opeh
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(opeh.PART_ID AS VARCHAR)
    WHERE opeh.TELEPHONE3 IS NOT NULL
       OR opeh.EMAIL_2 IS NOT NULL
),

opus_partner_hist AS (
    SELECT
        h.hk_prtnr_role_cd,
        oph.load_dt_tm AS ld_dt_tm,
        oph.record_source AS rcrd_src_nm,
        
        -- Contact columns
        oph.EMAIL AS EMAIL_ID,
        oph.TELEPHONE AS MOBILE_NO,
        CONCAT_WS(', ', oph.TELEPHONE2, oph.CONTACT1, oph.CONTACT2) AS ALT_MOBILE_NO,
        NULL AS LANDLINE_NO,
        NULL AS STD_CODE,
        NULL AS ALT_EMAIL_ID,
        NULL AS PREFERRED_CONTACT_OPT,
        oph.FAX,
        
        {{ hash_diff([
            'oph.TELEPHONE', 'oph.TELEPHONE2', 'oph.EMAIL', 'oph.FAX', 
            'oph.CONTACT1', 'oph.CONTACT2'
        ]) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_opus_partner_hist') }} oph
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(oph.PART_ID AS VARCHAR)
    WHERE oph.TELEPHONE IS NOT NULL
       OR oph.EMAIL IS NOT NULL
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_partner_extn
    UNION ALL
    SELECT * FROM opus_partner_extn_hist
    UNION ALL
    SELECT * FROM opus_partner_hist
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
