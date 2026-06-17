{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Dealer Repairer Details
-- Hub: hub_prtnr_role (dealer/repairer attributes per role)
-- Sources: MAXIMUS (simple property) + OPUS (clm_supplier_extn - workshop fields)

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
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,
        
        -- Dealer details
        sp.DEALER_CODE AS dealer_code,
        sp.DEALER_TYPE AS dealer_type,
        
        -- Repairer details
        sp.REPAIRER_PORTAL_ID AS repairer_code,
        NULL AS repairer_type,
        
        -- Rates / Financials
        sp.LABOR_RATE AS labor_rate,
        
        -- OPUS-only
        NULL AS workshop_category,
        NULL AS workshop_name,
        NULL AS workshop_class,
        NULL AS mfg_co_name,
        NULL AS spec_repairer,
        NULL AS towing_vehicle,
        NULL AS no_towing_vehicle,
        NULL AS ew_white_goods_flg,
        
        {{ hash_diff(['sp.DEALER_CODE', 'sp.DEALER_TYPE', 'sp.REPAIRER_PORTAL_ID', 'sp.LABOR_RATE']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_partner_simple_property') }} sp
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(sp.PARTY_CODE AS VARCHAR)
    WHERE sp.DEALER_CODE IS NOT NULL
       OR sp.REPAIRER_PORTAL_ID IS NOT NULL
),

opus_source AS (
    SELECT
        h.hk_prtnr_role_cd,
        ocs.load_dt_tm AS ld_dt_tm,
        ocs.record_source AS rcrd_src_nm,
        
        ocs.DEALER_CODE AS dealer_code,
        NULL AS dealer_type,
        NULL AS repairer_code,
        ocs.SPEC_REPAIRER AS repairer_type,
        NULL AS labor_rate,
        
        -- OPUS-only
        ocs.WORKSHOP_CATEGORY AS workshop_category,
        ocs.WORKSHOP_NAME AS workshop_name,
        ocs.WORKSHOP_CLASS AS workshop_class,
        ocs.MFG_CO_NAME AS mfg_co_name,
        ocs.SPEC_REPAIRER AS spec_repairer,
        ocs.TOWING_VEHICLE AS towing_vehicle,
        ocs.NO_TOWING_VEHICLE AS no_towing_vehicle,
        ocs.EW_WHITE_GOODS_FLG AS ew_white_goods_flg,
        
        {{ hash_diff(['ocs.DEALER_CODE', 'ocs.SPEC_REPAIRER', 'ocs.WORKSHOP_CATEGORY', 'ocs.WORKSHOP_NAME', 
                      'ocs.WORKSHOP_CLASS', 'ocs.MFG_CO_NAME', 'ocs.TOWING_VEHICLE', 'ocs.NO_TOWING_VEHICLE', 
                      'ocs.EW_WHITE_GOODS_FLG']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_clm_supplier_extn') }} ocs
    INNER JOIN hub_role h 
        ON ocs.PART_ID = h.PRTY_ID
    WHERE ocs.DEALER_CODE IS NOT NULL
       OR ocs.WORKSHOP_CATEGORY IS NOT NULL
       OR ocs.WORKSHOP_NAME IS NOT NULL
       OR ocs.SPEC_REPAIRER IS NOT NULL
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_source
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
