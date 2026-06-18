{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Hospital MOU Status Details
-- Hub: hub_prtnr_role (MOU/agreement status per hospital role)
-- Sources: MAXIMUS (simple property) + OPUS (hospital_master - MOU/discount/tariff)

WITH hub_role AS (
    SELECT 
        hk_prtnr_role_cd,
        prty_id,
        stake_cd
    FROM {{ ref('hub_prtnr_role') }}
    WHERE stake_cd = 'HOSPITAL'
),

maximus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,
        
        -- MOU details
        CAST(sp.MOU_STATUS AS VARCHAR) AS mou_status,
        sp.MOU_VALIDITY_START_DATE AS mou_start_date,
        sp.MOU_VALIDITY_END_DATE AS mou_end_date,
        NULL AS mou_renewal_date,
        CAST(sp.TYPE_OF_MOU AS VARCHAR) AS mou_type,
        NULL AS mou_signed_date,
        
        -- Blacklist / Suspension
        CAST(sp.BLACKLISTED AS VARCHAR) AS blacklist_status,
        CAST(sp.REASON_BLACKLISTED AS VARCHAR) AS blacklist_reason,
        sp.DATE_OF_BLACKLISTING AS blacklist_date,
        CAST(sp.SUSPENDED AS VARCHAR) AS suspended_status,
        CAST(sp.SUSPENDED_REASON AS VARCHAR) AS suspended_reason,
        sp.SUSPENDED_EFFECTIVE_DATE AS suspended_date,
        
        -- Discount / Tariff
        sp.DISCOUNT_PERCENTAGE AS discount_percentage,
        CAST(sp.DISCOUNT_TYPE AS VARCHAR) AS discount_type,
        CAST(sp.SPECIAL_TARIFF AS VARCHAR) AS tariff_type,
        NULL AS tariff_category,
        
        -- Advance
        sp.ADVANCE_AMOUNT AS advance_amount,
        CAST(sp.ADVANCE_PAYMENT_APPLICABLE AS VARCHAR) AS advance_status,
        sp.ADVANCE_PAYMENT_START_DATE AS advance_date,
        
        -- OPUS-only
        NULL AS imps_active_date,
        NULL AS imps_end_date,
        NULL AS imps_discnt,
        NULL AS imps_discnt_on,
        NULL AS imps_tarif_frm,
        NULL AS imps_tarif_to,
        NULL AS imps_payment_lmt,
        NULL AS early_discount,
        NULL AS payment_mode
    FROM {{ ref('stg_partner_simple_property') }} sp
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(sp.PARTY_CODE AS VARCHAR)
    WHERE sp.MOU_STATUS IS NOT NULL
),

opus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        ohm.load_dt_tm AS ld_dt_tm,
        ohm.record_source AS rcrd_src_nm,
        
        -- MOU (from hospital master)
        NULL AS mou_status,
        ohm.EFFECTIVE_DATE AS mou_start_date,
        ohm.EXPIRY_DATE AS mou_end_date,
        NULL AS mou_renewal_date,
        NULL AS mou_type,
        NULL AS mou_signed_date,
        
        -- Blacklist / Suspension (mapped from HOS_STATUS + DELETE_FLAG)
        CASE WHEN CAST(ohm.DELETE_FLAG AS VARCHAR) = 'Y' THEN 'BLACKLISTED' ELSE NULL END AS blacklist_status,
        CAST(ohm.HOS_REMARK AS VARCHAR) AS blacklist_reason,
        NULL AS blacklist_date,
        CASE WHEN CAST(ohm.HOS_STATUS AS VARCHAR) = 'SUSPENDED' THEN 'Y' ELSE NULL END AS suspended_status,
        NULL AS suspended_reason,
        NULL AS suspended_date,
        
        -- Discount / Tariff
        ohm.DISCOUNT AS discount_percentage,
        CAST(ohm.DISCOUNT_ON AS VARCHAR) AS discount_type,
        NULL AS tariff_type,
        NULL AS tariff_category,
        
        -- Advance
        NULL AS advance_amount,
        NULL AS advance_status,
        NULL AS advance_date,
        
        -- OPUS-only (IMPS = Instant Managed Payment System)
        ohm.IMPS_ACTIVE_DATE AS imps_active_date,
        ohm.IMPS_END_DATE AS imps_end_date,
        ohm.IMPS_DISCNT AS imps_discnt,
        CAST(ohm.IMPS_DISCNT_ON AS VARCHAR) AS imps_discnt_on,
        ohm.IMPS_TARIF_FRM AS imps_tarif_frm,
        ohm.IMPS_TARIF_TO AS imps_tarif_to,
        ohm.IMPS_PAYMENT_LMT AS imps_payment_lmt,
        ohm.EARLY_DISCOUNT AS early_discount,
        CAST(ohm.PAYMENT_MODE AS VARCHAR) AS payment_mode
    FROM {{ ref('stg_opus_hospital_master') }} ohm
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(ohm.PART_ID AS VARCHAR)
),

combined AS (
    SELECT *, 
        {{ hash_diff(['mou_status', 'mou_start_date', 'mou_end_date',
                      'blacklist_status', 'suspended_status', 'discount_percentage']) }} AS rcrd_hsh_id
    FROM maximus_source
    UNION ALL
    SELECT *, 
        {{ hash_diff(['mou_status', 'mou_start_date', 'mou_end_date',
                      'blacklist_status', 'suspended_status', 'discount_percentage']) }} AS rcrd_hsh_id
    FROM opus_source
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
