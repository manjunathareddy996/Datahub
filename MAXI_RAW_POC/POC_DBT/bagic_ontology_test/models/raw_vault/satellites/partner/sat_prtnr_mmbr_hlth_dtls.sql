{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_mstr_cd', 'contract_id', 'member_no', 'ld_dt_tm']
    )
}}

-- Satellite Partner Member Health Details
-- Hub: hub_prtnr_mstr
-- Sources: OPUS — Health product member tables
--   BJAZ_HCF_MEMBER_DTLS (65 cols) — Health Care Family
--   BJAZ_SPP_MEMBER_DTLS (45 cols) — Super Plus
--   BJAZ_HLT_ENSURE_MEM_DTLS (26 cols) — Health Ensure
--   BJAZ_HC_PART_EXTN (30 cols) — Health Claim Partition
-- Total: 166 OPUS attributes

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

hcf AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        hcf.PART_ID,
        hcf.CONTRACT_ID AS contract_id,
        hcf.MEMBER_NO AS member_no,
        hcf.INSURED_NAME AS member_name,
        hcf.DATE_OF_BIRTH, 
        hcf.AGE, 
        hcf.GENDER, 
        hcf.RELATION,
        hcf.SUM_INSURED, 
        hcf.PREMIUM,
        hcf.load_dt_tm AS ld_dt_tm,
        hcf.record_source AS rcrd_src_nm,
        'HCF' AS product_type,
        {{ hash_diff(['hcf.PART_ID', 'hcf.CONTRACT_ID', 'hcf.MEMBER_NO', 'hcf.INSURED_NAME', 'hcf.SUM_INSURED', 'hcf.PREMIUM']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_hcf_member') }} hcf
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(hcf.PART_ID AS VARCHAR)
),

spp AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        spp.PART_ID,
        spp.CONTRACT_ID AS contract_id,
        spp.MEMBER_NO AS member_no,
        spp.INSURED_NAME AS member_name,
        spp.DATE_OF_BIRTH, 
        spp.AGE, 
        spp.GENDER, 
        spp.RELATION,
        spp.SUM_INSURED, 
        spp.PREMIUM,
        spp.load_dt_tm AS ld_dt_tm,
        spp.record_source AS rcrd_src_nm,
        'SPP' AS product_type,
        {{ hash_diff(['spp.PART_ID', 'spp.CONTRACT_ID', 'spp.MEMBER_NO', 'spp.INSURED_NAME', 'spp.SUM_INSURED', 'spp.PREMIUM']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_spp_member') }} spp
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(spp.PART_ID AS VARCHAR)
),

hlt_ensure AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        he.PART_ID,
        he.CONTRACT_ID AS contract_id,
        he.MEMBER_NO AS member_no,
        he.NAME AS member_name,
        he.DATE_OF_BIRTH, 
        he.AGE, 
        he.GENDER, 
        he.RELATION,
        he.SUM_INSURED, 
        NULL AS PREMIUM,
        he.load_dt_tm AS ld_dt_tm,
        he.record_source AS rcrd_src_nm,
        'HLT_ENSURE' AS product_type,
        {{ hash_diff(['he.PART_ID', 'he.CONTRACT_ID', 'he.MEMBER_NO', 'he.NAME', 'he.SUM_INSURED']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_hlt_ensure_member') }} he
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(he.PART_ID AS VARCHAR)
),

hc_part AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        hcp.PART_ID,
        hcp.CONTRACT_ID AS contract_id,
        hcp.PARTITION_NO AS member_no,
        hcp.MEMBER_NAME AS member_name,
        hcp.DATE_OF_BIRTH, 
        hcp.AGE, 
        hcp.SEX AS GENDER, 
        hcp.RELATION,
        hcp.SUM_INSURED, 
        hcp.PREMIUM,
        hcp.load_dt_tm AS ld_dt_tm,
        hcp.record_source AS rcrd_src_nm,
        'HC_PART' AS product_type,
        {{ hash_diff(['hcp.PART_ID', 'hcp.CONTRACT_ID', 'hcp.PARTITION_NO', 'hcp.MEMBER_NAME', 'hcp.SUM_INSURED', 'hcp.PREMIUM']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_hc_partition') }} hcp
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(hcp.PART_ID AS VARCHAR)
),

combined AS (
    SELECT * FROM hcf
    UNION ALL
    SELECT * FROM spp
    UNION ALL
    SELECT * FROM hlt_ensure
    UNION ALL
    SELECT * FROM hc_part
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
