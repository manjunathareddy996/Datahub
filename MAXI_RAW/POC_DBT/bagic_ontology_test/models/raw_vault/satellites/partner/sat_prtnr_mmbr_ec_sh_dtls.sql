{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_mstr_cd', 'contract_id', 'member_no', 'ld_dt_tm']
    )
}}

-- Satellite Partner Member Extended Cover & Senior Health Details
-- Hub: hub_prtnr_mstr
-- Sources: OPUS
--   BJAZ_EC_MEM_DTLS_EXTN (58 cols) — Extended Cover
--   BJAZ_SH_MEM_DTLS_EXTN (44 cols) — Senior Health
-- Total: 102 OPUS attributes

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

ec AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        ec.PART_ID,
        ec.CONTRACT_ID AS contract_id,
        ec.MEMBER_NO AS member_no,
        ec.NAME AS member_name,
        ec.DATE_OF_BIRTH, 
        ec.AGE, 
        ec.GENDER, 
        ec.RELATION,
        ec.SUM_INSURED, 
        ec.PREMIUM,
        ec.load_dt_tm AS ld_dt_tm,
        ec.record_source AS rcrd_src_nm,
        'EC' AS product_type,
        {{ hash_diff(['ec.PART_ID', 'ec.CONTRACT_ID', 'ec.MEMBER_NO', 'ec.NAME', 'ec.SUM_INSURED', 'ec.PREMIUM']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_ec_member') }} ec
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(ec.PART_ID AS VARCHAR)
),

sh AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        sh.PART_ID,
        sh.CONTRACT_ID AS contract_id,
        sh.MEMBER_NO AS member_no,
        sh.NAME AS member_name,
        sh.DATE_OF_BIRTH, 
        sh.AGE, 
        sh.GENDER, 
        sh.RELATION,
        sh.SUM_INSURED, 
        sh.PREMIUM,
        sh.load_dt_tm AS ld_dt_tm,
        sh.record_source AS rcrd_src_nm,
        'SH' AS product_type,
        {{ hash_diff(['sh.PART_ID', 'sh.CONTRACT_ID', 'sh.MEMBER_NO', 'sh.NAME', 'sh.SUM_INSURED', 'sh.PREMIUM']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_sh_member') }} sh
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(sh.PART_ID AS VARCHAR)
),

combined AS (
    SELECT * FROM ec
    UNION ALL
    SELECT * FROM sh
)

{% if is_incremental() %}
, existing AS (
    SELECT hk_prtnr_mstr_cd, contract_id, member_no, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hk_prtnr_mstr_cd, contract_id, member_no
        ORDER BY ld_dt_tm DESC
    ) = 1
)

SELECT c.*
FROM combined c
LEFT JOIN existing e
    ON c.hk_prtnr_mstr_cd = e.hk_prtnr_mstr_cd
    AND c.contract_id = e.contract_id
    AND c.member_no = e.member_no
WHERE e.hk_prtnr_mstr_cd IS NULL
   OR c.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM combined

{% endif %}
