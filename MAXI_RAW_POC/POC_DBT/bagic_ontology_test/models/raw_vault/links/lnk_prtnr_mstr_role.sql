{{
    config(
        materialized='incremental',
        unique_key='hk_lnk_prtnr_mstr_role'
    )
}}

-- Link Partner Master to Role
-- Connects hub_prtnr_mstr to hub_prtnr_role (1:N relationship)
-- Proper Data Vault: Built from hubs, not source tables

WITH hub_mstr AS (
    SELECT 
        hk_prtnr_mstr_cd,
        prty_id,
        rcrd_src_nm
    FROM {{ ref('hub_prtnr_mstr') }}
),

hub_role AS (
    SELECT 
        hk_prtnr_role_cd,
        prty_id,
        stake_cd,
        rcrd_src_nm
    FROM {{ ref('hub_prtnr_role') }}
),

source AS (
    SELECT
        m.hk_prtnr_mstr_cd,
        r.hk_prtnr_role_cd,
        {{ hash(['m.hk_prtnr_mstr_cd', 'r.hk_prtnr_role_cd']) }} AS hk_lnk_prtnr_mstr_role,
        CURRENT_TIMESTAMP() AS ld_dt_tm,
        -- Use source from role hub (role determines the relationship source)
        r.rcrd_src_nm AS rcrd_src_nm
    FROM hub_role r
    INNER JOIN hub_mstr m 
        ON r.prty_id = m.prty_id
),

{% if is_incremental() %}
existing AS (
    SELECT hk_lnk_prtnr_mstr_role
    FROM {{ this }}
),
{% endif %}

new_records AS (
    SELECT DISTINCT
        hk_lnk_prtnr_mstr_role,
        hk_prtnr_mstr_cd,
        hk_prtnr_role_cd,
        ld_dt_tm,
        rcrd_src_nm
    FROM source
    {% if is_incremental() %}
    WHERE hk_lnk_prtnr_mstr_role NOT IN (SELECT hk_lnk_prtnr_mstr_role FROM existing)
    {% endif %}
)

SELECT * FROM new_records
