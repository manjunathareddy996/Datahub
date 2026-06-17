{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Profile Miscellaneous Details
-- Hub: hub_prtnr_role (catch-all for remaining profile attributes)
-- Sources: MAXIMUS (simple property) + OPUS (AZBJ_PARTNER_EXTN, BJAZ_AZBJ_PART_EXT_HIST,
--          BJAZ_CP_PART_HIST, CLM_INTERESTED_PARTIES, OCP_INTERESTED_PARTIES)
-- Per OPUS_MAPPING_FINAL: 69 OPUS columns land here

WITH hub_role AS (
    SELECT 
        hk_prtnr_role_cd,
        prty_id,
        stake_cd
    FROM {{ ref('hub_prtnr_role') }}
),

hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

multi_set AS (
    SELECT
        PARTY_CODE,
        STAKE_CODE,
        hk_prtnr_role_cd,
        TYPE_OF_PARTY,
        PARTY_STATUS
    FROM {{ ref('stg_partner_multiset_property') }}
),

maximus_source AS (
    SELECT
        h.hk_prtnr_role_cd,

        -- Metadata
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,

        -- MAXIMUS columns
        sp.REMARKS,
        sp.REFERENCE_CODE,
        sp.CATEGORY,
        sp.RATING,
        sp.EFFECTIVE_DATE,
        sp.EXPIRY_DATE,

        -- Placeholder for OPUS columns
        NULL AS PARENT_CO,
        NULL AS INDUSTRY,
        NULL AS PLACE_OF_BIRTH,
        NULL AS PA_CODE,
        NULL AS UCIC_FLAG,
        NULL AS HNI_FLAG,
        NULL AS MSME_FLAG,
        NULL AS VIP_CUST,
        NULL AS SUBCODE,
        NULL AS AVAILABILITY_TIME,
        NULL AS CAUSE_OF_DEATH,
        NULL AS DNI,
        NULL AS LUA_VALUE_1,
        NULL AS LUA_VALUE_2,
        NULL AS TAX_ID,
        NULL AS VAT_NUMBER,
        NULL AS NATIONAL_ID,
        NULL AS CLAIM_ID,
        NULL AS IP_NO,
        NULL AS IP_TYPE,
        NULL AS CLAIMANT,
        NULL AS OBJECT_TYPE,
        NULL AS OCP_PART_ID,
        NULL AS OCP_IP_NO,

        {{ hash_diff([
            'sp.REMARKS', 'sp.CATEGORY', 'sp.RATING', 'sp.EFFECTIVE_DATE', 'sp.EXPIRY_DATE'
        ]) }} AS rcrd_hsh_id

    FROM hub_role h
    INNER JOIN multi_set ms 
        ON h.prty_id = ms.PARTY_CODE 
        AND h.stake_cd = ms.STAKE_CODE
    LEFT JOIN {{ ref('stg_partner_simple_property') }} sp 
        ON h.prty_id = sp.PARTY_CODE
),

opus_partner_extn AS (
    SELECT
        hm.hk_prtnr_mstr_cd AS hk_prtnr_role_cd,
        ope.load_dt_tm AS ld_dt_tm,
        ope.record_source AS rcrd_src_nm,
        
        -- MAXIMUS placeholders
        NULL AS REMARKS,
        NULL AS REFERENCE_CODE,
        NULL AS CATEGORY,
        NULL AS RATING,
        NULL AS EFFECTIVE_DATE,
        NULL AS EXPIRY_DATE,
        
        -- OPUS partner_extn columns
        ope.PARENT_CO,
        ope.INDUSTRY,
        ope.PLACE_OF_BIRTH,
        ope.PA_CODE,
        ope.UCIC_FLAG,
        ope.HNI_FLAG,
        ope.MSME_FLAG,
        ope.VIP_CUST,
        NULL AS SUBCODE,
        NULL AS AVAILABILITY_TIME,
        NULL AS CAUSE_OF_DEATH,
        NULL AS DNI,
        NULL AS LUA_VALUE_1,
        NULL AS LUA_VALUE_2,
        NULL AS TAX_ID,
        NULL AS VAT_NUMBER,
        NULL AS NATIONAL_ID,
        NULL AS CLAIM_ID,
        NULL AS IP_NO,
        NULL AS IP_TYPE,
        NULL AS CLAIMANT,
        NULL AS OBJECT_TYPE,
        NULL AS OCP_PART_ID,
        NULL AS OCP_IP_NO,

        {{ hash_diff(['ope.PARENT_CO', 'ope.INDUSTRY', 'ope.PLACE_OF_BIRTH', 'ope.PA_CODE',
                      'ope.UCIC_FLAG', 'ope.HNI_FLAG', 'ope.MSME_FLAG', 'ope.VIP_CUST']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_partner_extn') }} ope
    INNER JOIN hub_mstr hm 
        ON hm.prty_id = CAST(ope.PART_ID AS VARCHAR)
),

opus_partner_extn_hist AS (
    SELECT
        hm.hk_prtnr_mstr_cd AS hk_prtnr_role_cd,
        opeh.load_dt_tm AS ld_dt_tm,
        opeh.record_source AS rcrd_src_nm,
        
        NULL AS REMARKS,
        NULL AS REFERENCE_CODE,
        NULL AS CATEGORY,
        NULL AS RATING,
        NULL AS EFFECTIVE_DATE,
        NULL AS EXPIRY_DATE,
        
        NULL AS PARENT_CO,
        opeh.INDUSTRY,
        opeh.PLACE_OF_BIRTH,
        opeh.PA_CODE,
        NULL AS UCIC_FLAG,
        NULL AS HNI_FLAG,
        NULL AS MSME_FLAG,
        opeh.VIP_CUST,
        opeh.SUBCODE,
        opeh.AVAILABILITY_TIME,
        NULL AS CAUSE_OF_DEATH,
        NULL AS DNI,
        NULL AS LUA_VALUE_1,
        NULL AS LUA_VALUE_2,
        NULL AS TAX_ID,
        NULL AS VAT_NUMBER,
        NULL AS NATIONAL_ID,
        NULL AS CLAIM_ID,
        NULL AS IP_NO,
        NULL AS IP_TYPE,
        NULL AS CLAIMANT,
        NULL AS OBJECT_TYPE,
        NULL AS OCP_PART_ID,
        NULL AS OCP_IP_NO,

        {{ hash_diff(['opeh.PA_CODE', 'opeh.SUBCODE', 'opeh.AVAILABILITY_TIME', 'opeh.INDUSTRY',
                      'opeh.PLACE_OF_BIRTH', 'opeh.VIP_CUST']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_partner_extn_hist') }} opeh
    INNER JOIN hub_mstr hm 
        ON hm.prty_id = CAST(opeh.PART_ID AS VARCHAR)
),

opus_partner_hist AS (
    SELECT
        hm.hk_prtnr_mstr_cd AS hk_prtnr_role_cd,
        oph.load_dt_tm AS ld_dt_tm,
        oph.record_source AS rcrd_src_nm,
        
        NULL AS REMARKS,
        NULL AS REFERENCE_CODE,
        NULL AS CATEGORY,
        NULL AS RATING,
        NULL AS EFFECTIVE_DATE,
        NULL AS EXPIRY_DATE,
        
        NULL AS PARENT_CO,
        NULL AS INDUSTRY,
        NULL AS PLACE_OF_BIRTH,
        NULL AS PA_CODE,
        NULL AS UCIC_FLAG,
        NULL AS HNI_FLAG,
        NULL AS MSME_FLAG,
        NULL AS VIP_CUST,
        NULL AS SUBCODE,
        NULL AS AVAILABILITY_TIME,
        oph.CAUSE_OF_DEATH,
        oph.DNI,
        oph.LUA_VALUE_1,
        oph.LUA_VALUE_2,
        oph.TAX_ID,
        oph.VAT_NUMBER,
        oph.NATIONAL_ID,
        NULL AS CLAIM_ID,
        NULL AS IP_NO,
        NULL AS IP_TYPE,
        NULL AS CLAIMANT,
        NULL AS OBJECT_TYPE,
        NULL AS OCP_PART_ID,
        NULL AS OCP_IP_NO,

        {{ hash_diff(['oph.CAUSE_OF_DEATH', 'oph.DNI', 'oph.LUA_VALUE_1', 'oph.LUA_VALUE_2',
                      'oph.TAX_ID', 'oph.VAT_NUMBER', 'oph.NATIONAL_ID']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_partner_hist') }} oph
    INNER JOIN hub_mstr hm 
        ON hm.prty_id = CAST(oph.PART_ID AS VARCHAR)
),

opus_clm_ip AS (
    SELECT
        hm.hk_prtnr_mstr_cd AS hk_prtnr_role_cd,
        ocip.load_dt_tm AS ld_dt_tm,
        ocip.record_source AS rcrd_src_nm,
        
        NULL AS REMARKS,
        NULL AS REFERENCE_CODE,
        NULL AS CATEGORY,
        NULL AS RATING,
        NULL AS EFFECTIVE_DATE,
        NULL AS EXPIRY_DATE,
        
        NULL AS PARENT_CO,
        NULL AS INDUSTRY,
        NULL AS PLACE_OF_BIRTH,
        NULL AS PA_CODE,
        NULL AS UCIC_FLAG,
        NULL AS HNI_FLAG,
        NULL AS MSME_FLAG,
        NULL AS VIP_CUST,
        NULL AS SUBCODE,
        NULL AS AVAILABILITY_TIME,
        NULL AS CAUSE_OF_DEATH,
        NULL AS DNI,
        NULL AS LUA_VALUE_1,
        NULL AS LUA_VALUE_2,
        NULL AS TAX_ID,
        NULL AS VAT_NUMBER,
        NULL AS NATIONAL_ID,
        ocip.CLAIM_ID,
        ocip.IP_NO,
        ocip.IP_TYPE,
        ocip.CLAIMANT,
        ocip.OBJECT_TYPE,
        NULL AS OCP_PART_ID,
        NULL AS OCP_IP_NO,

        {{ hash_diff(['ocip.CLAIM_ID', 'ocip.IP_NO', 'ocip.IP_TYPE', 'ocip.CLAIMANT', 'ocip.OBJECT_TYPE']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_clm_interested_parties') }} ocip
    INNER JOIN hub_mstr hm 
        ON hm.prty_id = CAST(ocip.PART_ID AS VARCHAR)
),

opus_ocp_ip AS (
    SELECT
        hm.hk_prtnr_mstr_cd AS hk_prtnr_role_cd,
        ooip.load_dt_tm AS ld_dt_tm,
        ooip.record_source AS rcrd_src_nm,
        
        NULL AS REMARKS,
        NULL AS REFERENCE_CODE,
        NULL AS CATEGORY,
        NULL AS RATING,
        NULL AS EFFECTIVE_DATE,
        NULL AS EXPIRY_DATE,
        
        NULL AS PARENT_CO,
        NULL AS INDUSTRY,
        NULL AS PLACE_OF_BIRTH,
        NULL AS PA_CODE,
        NULL AS UCIC_FLAG,
        NULL AS HNI_FLAG,
        NULL AS MSME_FLAG,
        NULL AS VIP_CUST,
        NULL AS SUBCODE,
        NULL AS AVAILABILITY_TIME,
        NULL AS CAUSE_OF_DEATH,
        NULL AS DNI,
        NULL AS LUA_VALUE_1,
        NULL AS LUA_VALUE_2,
        NULL AS TAX_ID,
        NULL AS VAT_NUMBER,
        NULL AS NATIONAL_ID,
        NULL AS CLAIM_ID,
        NULL AS IP_NO,
        NULL AS IP_TYPE,
        NULL AS CLAIMANT,
        NULL AS OBJECT_TYPE,
        ooip.PART_ID AS OCP_PART_ID,
        ooip.IP_NO AS OCP_IP_NO,

        {{ hash_diff(['ooip.PART_ID', 'ooip.IP_NO']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_ocp_interested_parties') }} ooip
    INNER JOIN hub_mstr hm 
        ON hm.prty_id = CAST(ooip.PART_ID AS VARCHAR)
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_partner_extn
    UNION ALL
    SELECT * FROM opus_partner_extn_hist
    UNION ALL
    SELECT * FROM opus_partner_hist
    UNION ALL
    SELECT * FROM opus_clm_ip
    UNION ALL
    SELECT * FROM opus_ocp_ip
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
