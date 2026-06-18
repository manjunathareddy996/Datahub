{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_mstr_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Common Details
-- Hub: hub_prtnr_mstr (person-level, role-independent)
-- Sources: MAXIMUS (stg_partner_detail + stg_partner_simple_property)
--        + OPUS (CP_PARTNERS + AZBJ_PARTNER_EXTN + BJAZ_AZBJ_PART_EXT_HIST + BJAZ_CP_PART_HIST)
-- Per OPUS_MAPPING_FINAL: 95 OPUS columns land here

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

maximus_source AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        d.load_dt_tm AS ld_dt_tm,
        d.record_source AS rcrd_src_nm,
        d.PARTY_CODE AS part_id,
        
        -- Common columns
        d.FIRST_NAME,
        d.LAST_NAME,
        d.MIDDLE_NAME,
        d.GENDER,
        CAST(d.DATE_OF_BIRTH AS VARCHAR) AS DATE_OF_BIRTH,
        d.NATIONALITY,
        d.OCCUPATION,
        d.PARTY_STATUS,
        d.TYPE_OF_PARTY,
        
        {{ hash_diff([
            'd.FIRST_NAME', 'd.LAST_NAME', 'd.GENDER',
            'd.DATE_OF_BIRTH', 'd.NATIONALITY', 'd.OCCUPATION',
            'd.PARTY_STATUS', 'd.TYPE_OF_PARTY'
        ]) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_partner_detail') }} d
    INNER JOIN hub_mstr h 
        ON h.prty_id = d.PARTY_CODE
),

opus_cp_partners AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        op.load_dt_tm AS ld_dt_tm,
        op.record_source AS rcrd_src_nm,
        op.PART_ID AS part_id,
        
        -- Common columns
        op.FIRST_NAME,
        op.SURNAME AS LAST_NAME,
        op.MIDDLE_NAME,
        op.SEX AS GENDER,
        CAST(op.DATE_OF_BIRTH AS VARCHAR) AS DATE_OF_BIRTH,
        op.NATIONALITY,
        op.OCCUPATION,
        op.DATA_STATUS AS PARTY_STATUS,
        op.PARTNER_TYPE AS TYPE_OF_PARTY,
        
        {{ hash_diff([
            'op.FIRST_NAME', 'op.SURNAME', 'op.SEX',
            'op.DATE_OF_BIRTH', 'op.NATIONALITY', 'op.OCCUPATION',
            'op.DATA_STATUS', 'op.PARTNER_TYPE'
        ]) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_opus_partner') }} op
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(op.PART_ID AS VARCHAR)
),

opus_partner_extn AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        ope.load_dt_tm AS ld_dt_tm,
        ope.record_source AS rcrd_src_nm,
        ope.PART_ID AS part_id,
        
        -- Common columns (mostly NULL for extn)
        NULL AS FIRST_NAME,
        NULL AS LAST_NAME,
        NULL AS MIDDLE_NAME,
        NULL AS GENDER,
        NULL AS DATE_OF_BIRTH,
        NULL AS NATIONALITY,
        ope.OCCUPATION_DESC_GEN AS OCCUPATION,
        ope.STATUS AS PARTY_STATUS,
        NULL AS TYPE_OF_PARTY,
        
        {{ hash_diff([
            'ope.PART_ID', 'ope.OCCUPATION_DESC_GEN', 'ope.STATUS'
        ]) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_opus_partner_extn') }} ope
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(ope.PART_ID AS VARCHAR)
),

opus_partner_hist AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        oph.load_dt_tm AS ld_dt_tm,
        oph.record_source AS rcrd_src_nm,
        oph.PART_ID AS part_id,
        
        -- Common columns
        oph.FIRST_NAME,
        oph.SURNAME AS LAST_NAME,
        oph.MIDDLE_NAME,
        oph.SEX AS GENDER,
        CAST(oph.DATE_OF_BIRTH AS VARCHAR) AS DATE_OF_BIRTH,
        oph.NATIONALITY,
        oph.OCCUPATION,
        oph.DATA_STATUS AS PARTY_STATUS,
        oph.PARTNER_TYPE AS TYPE_OF_PARTY,
        
        {{ hash_diff([
            'oph.FIRST_NAME', 'oph.SURNAME', 'oph.SEX',
            'oph.DATE_OF_BIRTH', 'oph.NATIONALITY', 'oph.OCCUPATION',
            'oph.DATA_STATUS', 'oph.PARTNER_TYPE'
        ]) }} AS rcrd_hsh_id
        
    FROM {{ ref('stg_opus_partner_hist') }} oph
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(oph.PART_ID AS VARCHAR)
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_cp_partners
    UNION ALL
    SELECT * FROM opus_partner_extn
    UNION ALL
    SELECT * FROM opus_partner_hist
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
