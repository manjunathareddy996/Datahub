{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Surveyor Investigator Details
-- Hub: hub_prtnr_role (SURVEYOR/INVESTIGATOR/DEALER/REPAIRER/LAWYER roles)
-- Sources: MAXIMUS (simple property) + OPUS (BJAZ_CLM_SUPP_EXTN + CLM_SUPPLIERS)
-- Per OPUS_MAPPING_FINAL: ALL 127 columns from these 2 OPUS tables land here

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
        
        -- Surveyor details from simple property
        NULL AS supp_id,
        sp.TYPE_OF_SURVEYOR AS surveyor_category,
        sp.SUR_LICENSE_NO AS surveyor_license_no,
        NULL AS grade,
        NULL AS class,
        NULL AS supp_type,
        NULL AS supp_status,
        
        {{ hash_diff(['sp.TYPE_OF_SURVEYOR', 'sp.SUR_LICENSE_NO']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_partner_simple_property') }} sp
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(sp.PARTY_CODE AS VARCHAR)
    WHERE sp.TYPE_OF_SURVEYOR IS NOT NULL 
       OR sp.SUR_LICENSE_NO IS NOT NULL
),

opus_supp_extn AS (
    SELECT
        h.hk_prtnr_role_cd,
        ose.load_dt_tm AS ld_dt_tm,
        ose.record_source AS rcrd_src_nm,
        
        ose.SUPP_ID AS supp_id,
        ose.SURVEYOR_CATEGORY AS surveyor_category,
        ose.SURVEYOR_LICENSE_NO AS surveyor_license_no,
        ose.GRADE AS grade,
        ose.CLASS AS class,
        NULL AS supp_type,
        NULL AS supp_status,
        
        {{ hash_diff(['ose.SUPP_ID', 'ose.SURVEYOR_CATEGORY', 'ose.SURVEYOR_LICENSE_NO',
                      'ose.GRADE', 'ose.CLASS']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_clm_supplier_extn') }} ose
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(ose.PART_ID AS VARCHAR)
),

opus_supplier AS (
    SELECT
        h.hk_prtnr_role_cd,
        os.load_dt_tm AS ld_dt_tm,
        os.record_source AS rcrd_src_nm,
        
        os.SUPP_ID AS supp_id,
        NULL AS surveyor_category,
        NULL AS surveyor_license_no,
        NULL AS grade,
        NULL AS class,
        os.SUPP_TYPE AS supp_type,
        os.SUPP_STATUS AS supp_status,
        
        {{ hash_diff(['os.SUPP_ID', 'os.SUPP_TYPE', 'os.SUPP_STATUS']) }} AS rcrd_hsh_id
    FROM {{ ref('stg_opus_clm_supplier') }} os
    INNER JOIN hub_role h 
        ON h.prty_id = CAST(os.PART_ID AS VARCHAR)
),

combined AS (
    SELECT * FROM maximus_source
    UNION ALL
    SELECT * FROM opus_supp_extn
    UNION ALL
    SELECT * FROM opus_supplier
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
