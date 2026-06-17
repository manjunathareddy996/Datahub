{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_mstr_cd', 'contract_id', 'member_no', 'ld_dt_tm']
    )
}}

-- Satellite Partner Member Group/Corporate Details
-- Hub: hub_prtnr_mstr
-- Sources: OPUS — Group/Corporate product member tables
--   BJAZ_HM_MEMBER_DTLS (61 cols) — Health Mediclaim (Group/Retail)
--   BA_HCP_DT_MEM (10 cols) — Legacy HCP Corporate
--   BJAZ_CTNGY_GC_MEM_DATA (18 cols) — Contingency Group Corporate
-- Total: 89 OPUS attributes

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

hm AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        hm.PART_ID,
        hm.CONTRACT_ID AS contract_id,
        hm.MEMBER_ID AS member_no,
        hm.MEMBER_NAME AS member_name,
        hm.DOB AS DATE_OF_BIRTH, 
        hm.AGE, 
        hm.GENDER, 
        hm.RELATION,
        hm.SUMINSURED AS SUM_INSURED, 
        hm.PREMIUM,
        hm.load_dt_tm AS ld_dt_tm,
        hm.record_source AS rcrd_src_nm,
        'HM' AS product_type,
        {{ hash_diff(['hm.PART_ID', 'hm.CONTRACT_ID', 'hm.MEMBER_ID', 'hm.MEMBER_NAME', 'hm.SUMINSURED', 'hm.PREMIUM']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_hm_member') }} hm
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(hm.PART_ID AS VARCHAR)
),

ba_hcp AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        ba.PART_ID,
        ba.CONTRACT_ID AS contract_id,
        ba.MEM_SEQNO AS member_no,
        ba.MEMBER_NAME AS member_name,
        NULL AS DATE_OF_BIRTH, 
        NULL AS AGE, 
        NULL AS GENDER, 
        NULL AS RELATION,
        NULL AS SUM_INSURED, 
        NULL AS PREMIUM,
        ba.load_dt_tm AS ld_dt_tm,
        ba.record_source AS rcrd_src_nm,
        'BA_HCP' AS product_type,
        {{ hash_diff(['ba.PART_ID', 'ba.CONTRACT_ID', 'ba.MEM_SEQNO', 'ba.MEMBER_NAME']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_ba_hcp_member') }} ba
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(ba.PART_ID AS VARCHAR)
),

gc AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        gc.PART_ID,
        gc.POLICY_REF AS contract_id,
        NULL AS member_no,
        gc.MEMBER_NAME AS member_name,
        gc.DATE_OF_BIRTH, 
        gc.AGE, 
        gc.GENDER, 
        gc.RELATION,
        gc.SUM_INSURED, 
        NULL AS PREMIUM,
        gc.load_dt_tm AS ld_dt_tm,
        gc.record_source AS rcrd_src_nm,
        'GC' AS product_type,
        {{ hash_diff(['gc.PART_ID', 'gc.POLICY_REF', 'gc.MEMBER_NAME', 'gc.DATE_OF_BIRTH', 'gc.SUM_INSURED']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_ctngy_gc_member') }} gc
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(gc.PART_ID AS VARCHAR)
),

combined AS (
    SELECT * FROM hm
    UNION ALL
    SELECT * FROM ba_hcp
    UNION ALL
    SELECT * FROM gc
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
    AND COALESCE(c.member_no, '') = COALESCE(e.member_no, '')
WHERE e.hk_prtnr_mstr_cd IS NULL
   OR c.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM combined

{% endif %}
