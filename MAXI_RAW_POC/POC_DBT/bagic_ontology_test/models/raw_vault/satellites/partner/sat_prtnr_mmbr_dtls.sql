{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Member Details
-- Hub: hub_prtnr_role (member enrollment data per role)
-- Source: SIMPLE_PROPERTY_PIVOT + MULTI_SET_PROPERTY
-- Domain: Age, BMI, sum insured, premium, cover, health card

WITH hub_role AS (
    SELECT 
        hk_prtnr_role_cd,
        prty_id,
        stake_cd
    FROM {{ ref('hub_prtnr_role') }}
),

multi_set AS (
    SELECT
        PARTY_CODE,
        STAKE_CODE,
        hk_prtnr_role_cd,
        TYPE_OF_PARTY,
        PARTY_STATUS
    FROM {{ ref('stg_partner_multiset_property') }}
),

source AS (
    SELECT
        h.hk_prtnr_role_cd,
        h.prty_id AS PARTY_CODE,
        h.stake_cd AS STAKE_CODE,

        -- Semantic reference columns
        ms.TYPE_OF_PARTY AS partner_type,
        ms.PARTY_STATUS AS status,

        -- Member demographics
        sp.AGE,
        NULL AS BMI,
        sp.HEIGHT,
        sp.WEIGHT,
        NULL AS BLOOD_GROUP,

        -- Insurance coverage
        NULL AS SUM_INSURED,
        NULL AS SUM_INSURED_TYPE,
        NULL AS PREMIUM,
        NULL AS PREMIUM_AMOUNT,
        NULL AS COVER_TYPE,
        NULL AS COVER_START_DATE,
        NULL AS COVER_END_DATE,
        NULL AS COVER_PERIOD,

        -- Health card
        NULL AS HEALTH_CARD_NUMBER,
        NULL AS HEALTH_CARD_ISSUE_DATE,
        NULL AS HEALTH_CARD_VALID_TILL,
        NULL AS HEALTH_CARD_STATUS,

        -- Member classification
        sp.MEMBER_TYPE,
        NULL AS MEMBER_STATUS,
        NULL AS MEMBER_CODE,

        -- Metadata
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,

        {{ hash_diff([
            'sp.AGE', 'sp.HEIGHT', 'sp.WEIGHT', 'sp.MEMBER_TYPE'
        ]) }} AS rcrd_hsh_id

    FROM hub_role h
    INNER JOIN multi_set ms 
        ON h.prty_id = ms.PARTY_CODE 
        AND h.stake_cd = ms.STAKE_CODE
    LEFT JOIN {{ ref('stg_partner_simple_property') }} sp 
        ON h.prty_id = sp.PARTY_CODE
)

{% if is_incremental() %}

SELECT s.*
FROM source s
LEFT JOIN (
    SELECT hk_prtnr_role_cd, rcrd_hsh_id
    FROM {{ this }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY hk_prtnr_role_cd ORDER BY ld_dt_tm DESC) = 1
) e ON s.hk_prtnr_role_cd = e.hk_prtnr_role_cd
WHERE e.hk_prtnr_role_cd IS NULL
   OR s.rcrd_hsh_id != e.rcrd_hsh_id

{% else %}

SELECT * FROM source

{% endif %}
