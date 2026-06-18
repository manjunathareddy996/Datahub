{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_mstr_cd', 'contract_id', 'member_no', 'ld_dt_tm']
    )
}}

-- Satellite Partner Member PA & Family Floater Details
-- Hub: hub_prtnr_mstr
-- Sources: OPUS
--   BJAZ_PA_DETL_EXTN (24 cols) — Personal Accident
--   BJAZ_STARPKG_FF_DTLS (23 cols) — Star Package Family Floater
--   BJAZ_CTNGY_FF_DTLS_EXTN (19 cols) — Contingency Family Floater
-- Total: 66 OPUS attributes

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

pa AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        pa.PART_ID,
        pa.CONTRACT_ID AS contract_id,
        pa.REF_NO AS member_no,
        pa.MEMBER_NAME AS member_name,
        pa.DOB AS DATE_OF_BIRTH, 
        CAST(pa.AGE AS VARCHAR) AS AGE, 
        NULL AS GENDER, 
        pa.RELATION,
        pa.SUM_INSU_BASIC AS SUM_INSURED, 
        NULL AS PREMIUM,
        pa.load_dt_tm AS ld_dt_tm,
        pa.record_source AS rcrd_src_nm,
        'PA' AS product_type,
        {{ hash_diff(['pa.PART_ID', 'pa.CONTRACT_ID', 'pa.REF_NO', 'pa.MEMBER_NAME', 'pa.SUM_INSU_BASIC']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_pa_detail') }} pa
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(pa.PART_ID AS VARCHAR)
),

starpkg AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        sp.PART_ID,
        sp.CONTRACT_ID AS contract_id,
        sp.SR_NO AS member_no,
        sp.MEMBER_NAME AS member_name,
        sp.DOB AS DATE_OF_BIRTH, 
        CAST(sp.AGE AS VARCHAR) AS AGE, 
        sp.GENDER, 
        sp.RELATION,
        NULL AS SUM_INSURED, 
        sp.FULL_PREMIUM AS PREMIUM,
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,
        'STARPKG' AS product_type,
        {{ hash_diff(['sp.PART_ID', 'sp.CONTRACT_ID', 'sp.SR_NO', 'sp.MEMBER_NAME', 'sp.FULL_PREMIUM']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_starpkg_member') }} sp
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(sp.PART_ID AS VARCHAR)
),

ctngy_ff AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        cf.PART_ID,
        cf.CONTRACT_ID AS contract_id,
        cf.SR_NO AS member_no,
        cf.MEMBER_NAME AS member_name,
        cf.DOB AS DATE_OF_BIRTH, 
        NULL AS AGE, 
        cf.GENDER, 
        cf.RELATION,
        NULL AS SUM_INSURED, 
        cf.PREMIUM,
        cf.load_dt_tm AS ld_dt_tm,
        cf.record_source AS rcrd_src_nm,
        'CTNGY_FF' AS product_type,
        {{ hash_diff(['cf.PART_ID', 'cf.CONTRACT_ID', 'cf.SR_NO', 'cf.MEMBER_NAME', 'cf.PREMIUM']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_ctngy_ff_member') }} cf
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(cf.PART_ID AS VARCHAR)
),

combined AS (
    SELECT * FROM pa
    UNION ALL
    SELECT * FROM starpkg
    UNION ALL
    SELECT * FROM ctngy_ff
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
