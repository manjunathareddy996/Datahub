{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_mstr_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Member Miscellaneous Details
-- Hub: hub_prtnr_mstr
-- Sources: OPUS
--   AZBJ_PARTNER_EXTN (2 cols) — AA_MEMBERSHIP_NUMBER, AA_MEMBERSHIP_EXPIRY_DATE
--   BJAZ_AZBJ_PART_EXT_HIST (2 cols) — same fields (history)
--   OCP_INTERESTED_PARTIES (1 col) — CONTRACT_ID
-- Total: 5 OPUS attributes (membership reference, not per-member grain)

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id
    FROM {{ ref('hub_prtnr_mstr') }}
),

opus_partner_extn AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        ope.load_dt_tm AS ld_dt_tm,
        ope.record_source AS rcrd_src_nm,

        ope.AA_MEMBERSHIP_NUMBER,
        ope.AA_MEMBERSHIP_EXPIRY_DATE,

        {{ hash_diff([
            'ope.AA_MEMBERSHIP_NUMBER', 'ope.AA_MEMBERSHIP_EXPIRY_DATE'
        ]) }} AS rcrd_hsh_id

    FROM {{ ref('stg_opus_partner_extn') }} ope
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(ope.PART_ID AS VARCHAR)
    WHERE ope.AA_MEMBERSHIP_NUMBER IS NOT NULL
),

opus_partner_extn_hist AS (
    SELECT
        h.hk_prtnr_mstr_cd,
        opeh.load_dt_tm AS ld_dt_tm,
        opeh.record_source AS rcrd_src_nm,

        opeh.AA_MEMBERSHIP_NUMBER,
        opeh.AA_MEMBERSHIP_EXPIRY_DATE,

        {{ hash_diff([
            'opeh.AA_MEMBERSHIP_NUMBER', 'opeh.AA_MEMBERSHIP_EXPIRY_DATE'
        ]) }} AS rcrd_hsh_id

    FROM {{ ref('stg_opus_partner_extn_hist') }} opeh
    INNER JOIN hub_mstr h 
        ON h.prty_id = CAST(opeh.PART_ID AS VARCHAR)
    WHERE opeh.AA_MEMBERSHIP_NUMBER IS NOT NULL
),

combined AS (
    SELECT * FROM opus_partner_extn
    UNION ALL
    SELECT * FROM opus_partner_extn_hist
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
