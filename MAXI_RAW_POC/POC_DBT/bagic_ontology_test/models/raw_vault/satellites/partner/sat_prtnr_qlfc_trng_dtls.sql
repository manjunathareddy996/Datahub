{{
    config(
        materialized='incremental',
        unique_key=['hk_prtnr_role_cd', 'ld_dt_tm']
    )
}}

-- Satellite Partner Qualification Training Details
-- Hub: hub_prtnr_role (qualification/training per role)
-- Source: stg_partner_simple_property + stg_partner_multiset_property
-- Domain: Qualifications, training, previous company, certificates

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

        -- Qualification details
        sp.QUALIFICATION_DETAILS AS QUALIFICATION,
        NULL AS QUALIFICATION_TYPE,
        sp.QUALIFICATION_DETAILS,
        sp.HIGHEST_QUALIFICATION_DETAILS AS HIGHEST_QUALIFICATION,
        sp.PROFESSIONAL_QUALIFICATION,

        -- Training details
        sp.TRAINING_IS_REQUIRED_TO_BE_GIVEN_TO_THE_EMPLOYEES_OF_THE_SERVICE_PROVIDER AS TRAINING_COMPLETED,
        NULL AS TRAINING_DATE,
        NULL AS TRAINING_TYPE,
        NULL AS TRAINING_CERTIFICATE_NUMBER,
        NULL AS TRAINING_VALID_TILL,

        -- Previous company
        sp.PREVIOUS_COMPANY_NAME,
        NULL AS PREVIOUS_COMPANY_CODE,
        sp.OVERALL_EXPERIENCE AS PREVIOUS_EXPERIENCE,

        -- Certificates
        sp.CERTIFICATION_NO AS CERTIFICATE_NUMBER,
        NULL AS CERTIFICATE_DATE,
        NULL AS CERTIFICATE_VALID_TILL,

        -- Metadata
        msp.load_dt_tm AS ld_dt_tm,
        msp.record_source AS rcrd_src_nm,

        {{ hash_diff([
            'sp.QUALIFICATION_DETAILS', 'sp.HIGHEST_QUALIFICATION_DETAILS',
            'sp.PROFESSIONAL_QUALIFICATION', 'sp.PREVIOUS_COMPANY_NAME',
            'sp.OVERALL_EXPERIENCE', 'sp.CERTIFICATION_NO'
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
