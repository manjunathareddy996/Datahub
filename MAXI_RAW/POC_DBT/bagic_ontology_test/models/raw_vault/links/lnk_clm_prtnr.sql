{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_clm_prtnr'
    )
}}

-- Link Claim to Partner
-- Connects hub_clm to hub_prtnr_mstr (partner involvement in a claim)
-- Sources: OPUS (CLM_INTERESTED_PARTIES) — MAXIMUS claim-partner link TBD

WITH opus_source AS (
    SELECT
        PART_ID,
        CLAIM_ID,
        IP_TYPE,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,
        {{ hash('CLAIM_ID') }} AS hk_clm_cd,
        {{ hash(['CLAIM_ID', 'PART_ID', 'IP_TYPE']) }} AS hk_lnk_clm_prtnr,
        load_dt_tm AS ld_dt_tm,
        record_source AS rcrd_src_nm
    FROM {{ ref('stg_opus_clm_interested_parties') }}
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_clm_prtnr
    FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_clm_prtnr,
        hk_clm_cd,
        hk_prtnr_mstr_cd,
        IP_TYPE AS ip_type,
        ld_dt_tm,
        rcrd_src_nm
    FROM opus_source
    {% if is_incremental() %}
    WHERE hk_lnk_clm_prtnr NOT IN (SELECT hk_lnk_clm_prtnr FROM existing)
    {% endif %}
)

SELECT * FROM new_records
