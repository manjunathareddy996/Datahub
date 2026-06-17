{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Insurance LOB Profile Details
-- Hub: hub_prtnr_role (insurance line-of-business profile per role)
-- Source: stg_partner_multiset_property (LOB flags) + stg_partner_simple_property (product details)
-- Domain: Fire, motor, health, travel, marine, engineering, aviation, crop, product flags

WITH hub_role AS (
    SELECT hk_prtnr_role_cd, prty_id, stake_cd
    FROM {{ ref('hub_prtnr_role') }}
),

source AS (
    SELECT
        h.hk_prtnr_role_cd,
        msp.PARTY_CODE,
        msp.STAKE_CODE,

        -- Semantic reference columns
        sp.TYPE_OF_PARTY AS partner_type,
        sp.STATUS AS status,

        -- LOB flags / profiles (from multiset)
        msp.FIRE,
        msp.MOTOR,
        msp.HEALTH,
        msp.TRAVEL,
        msp.MARINE_CARGO,
        msp.MARINE_HULL,
        msp.ENGINEERING,
        msp.AVIATION,
        msp.CROP_INSURANCE,
        NULL AS CROP_TYPE,

        -- Product details (from simple property)
        sp.PRODUCT_CODE,
        NULL AS PRODUCT_NAME,
        sp.PRODUCT_DETAILS,
        NULL AS PRODUCT_CATEGORY,

        -- LOB-specific limits
        NULL AS FIRE_LIMIT,
        NULL AS MOTOR_LIMIT,
        NULL AS HEALTH_LIMIT,
        NULL AS MARINE_LIMIT,

        -- Add remaining columns from 03_SATELLITES.csv for full implementation

        -- Metadata
        msp.load_dt_tm AS ld_dt_tm,
        msp.record_source AS rcrd_src_nm,

        {{ hash_diff([
            'msp.FIRE', 'msp.MOTOR', 'msp.HEALTH', 'msp.TRAVEL',
            'msp.MARINE_CARGO', 'msp.ENGINEERING', 'msp.AVIATION',
            'sp.PRODUCT_CODE', 'sp.PRODUCT_DETAILS'
        ]) }} AS rcrd_hsh_id

    FROM {{ ref('stg_partner_multiset_property') }} msp
    INNER JOIN hub_role h
        ON msp.PARTY_CODE = h.prty_id
        AND msp.STAKE_CODE = h.stake_cd
    INNER JOIN {{ ref('stg_partner_simple_property') }} sp
        ON msp.PARTY_CODE = sp.PARTY_CODE
)

{% if is_incremental() %}
, existing AS (
    SELECT hk_prtnr_role_cd, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_prtnr_role_cd ORDER BY ld_dt_tm DESC) = 1
)

SELECT s.*
FROM source s
LEFT JOIN existing e ON s.hk_prtnr_role_cd = e.hk_prtnr_role_cd
WHERE e.hk_prtnr_role_cd IS NULL
   OR s.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM source

{% endif %}
