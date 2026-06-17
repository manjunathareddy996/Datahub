{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_plcy_prtnr'
    )
}}

-- Link Policy to Partner
-- Connects hub_plcy (via CONTRACT_ID) to hub_prtnr_mstr
-- Sources: OPUS (OCP_INTERESTED_PARTIES) — MAXIMUS policy-partner link from stg_partner_detail

WITH opus_source AS (
    SELECT
        PART_ID,
        CONTRACT_ID,
        {{ hash('PART_ID') }} AS hk_prtnr_mstr_cd,
        {{ hash('CONTRACT_ID') }} AS hk_plcy_cd,
        {{ hash(['CONTRACT_ID', 'PART_ID']) }} AS hk_lnk_plcy_prtnr,
        load_dt_tm AS ld_dt_tm,
        record_source AS rcrd_src_nm
    FROM {{ ref('stg_opus_ocp_interested_parties') }}
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_plcy_prtnr
    FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_plcy_prtnr,
        hk_plcy_cd,
        hk_prtnr_mstr_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM opus_source
    {% if is_incremental() %}
    WHERE hk_lnk_plcy_prtnr NOT IN (SELECT hk_lnk_plcy_prtnr FROM existing)
    {% endif %}
)

SELECT * FROM new_records
