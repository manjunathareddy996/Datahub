{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Business Compliance Details
-- Hub: hub_prtnr_role (business compliance per role)
-- Source: SIMPLE_PROPERTY_PIVOT + MULTI_SET_PROPERTY
-- Domain: GST, registration, statewise GSTIN, business details
-- Per OPUS_MAPPING_FINAL: No OPUS columns map here (GST → agnt_dtls, PAN → srvyr)

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

        -- GST details
        NULL AS GST_APPLICABLE,
        sp.GSTINUIN AS GST_NUMBER,
        sp.GSTIN_ISSUANCE_DT AS GST_REGISTRATION_DATE,
        NULL AS GST_STATE,
        NULL AS GST_TYPE,
        sp.GSTINUIN AS GSTIN,
        sp.GSTN_NUMBER AS GSTIN_NUMBER,

        -- Statewise GSTIN
        sp.STATEWISE_GSTIN_DETAILS AS STATEWISE_GSTIN_1,
        NULL AS STATEWISE_GSTIN_2,
        NULL AS STATEWISE_GSTIN_3,
        NULL AS STATEWISE_GSTIN_STATE_1,
        NULL AS STATEWISE_GSTIN_STATE_2,

        -- Registration
        sp.REGISTRATION_NO AS REGISTRATION_NUMBER,
        sp.SEZ_REGISTRATION_DATE AS REGISTRATION_DATE,
        NULL AS REGISTRATION_VALID_TILL,
        NULL AS REGISTRATION_TYPE,

        -- Business details
        sp.BUSINESS_TYPE,
        NULL AS BUSINESS_CATEGORY,
        NULL AS BUSINESS_NATURE,

        -- Metadata
        sp.load_dt_tm AS ld_dt_tm,
        sp.record_source AS rcrd_src_nm,

        {{ hash_diff([
            'sp.GSTINUIN', 'sp.GSTN_NUMBER',
            'sp.REGISTRATION_NO', 'sp.SEZ_REGISTRATION_DATE',
            'sp.BUSINESS_TYPE'
        ]) }} AS rcrd_hsh_id

    FROM hub_role h
    INNER JOIN multi_set ms 
        ON h.prty_id = ms.PARTY_CODE 
        AND h.stake_cd = ms.STAKE_CODE
    LEFT JOIN {{ ref('stg_partner_simple_property') }} sp 
        ON h.prty_id = sp.PARTY_CODE
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
