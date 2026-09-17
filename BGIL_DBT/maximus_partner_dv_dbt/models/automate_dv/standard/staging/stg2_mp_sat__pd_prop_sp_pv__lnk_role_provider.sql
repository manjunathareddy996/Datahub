{{ config(materialized='view') }}

-- Per-satellite projection of the wide stage for SAT_LNK_ROLE_PROVIDER.
--
-- Two jobs, both pure renames -- no expressions, no re-hashing:
--
--   1. HASHDIFF_LNK_ROLE_PROVIDER -> HASHDIFF. The wide stage carries ~40 hashdiffs (one per
--      satellite) so it cannot name any of them plain HASHDIFF, but the shared vault table has a
--      single HASHDIFF column that partner_dv_dbt already populates. Aliasing here rather than in
--      the wide stage matters: the hash VALUE was computed upstream and is untouched, so no
--      existing row re-hashes and no spurious versions are generated.
--
--   2. Three payload columns renamed to the names partner_dv_dbt already writes, so the shared
--      table does not end up with semantically duplicated column pairs:
--          EMPANELMENTDATE -> EMPANELMENT_DATE
--          PROVIDERTYPE    -> PROVIDER_TYPE
--          PROVIDERCODE    -> SUPPLIER_ID     (both derive from the supplier id)
--      SPECIALISATION already matches on both sides.
--
-- The remaining 12 columns are genuinely Maximus-only and have no partner equivalent. Those are
-- the ones on_schema_change='append_new_columns' will ALTER TABLE ADD COLUMN on first run.

SELECT
    PARTY_HKEY,
    HASHDIFF_LNK_ROLE_PROVIDER AS HASHDIFF,

    -- aligned with partner_dv_dbt's existing column names
    EMPANELMENTDATE            AS EMPANELMENT_DATE,
    PROVIDERTYPE               AS PROVIDER_TYPE,
    PROVIDERCODE               AS SUPPLIER_ID,
    SPECIALISATION,

    -- Maximus-only payload: appended to the shared table by append_new_columns
    DEEMPANELMENTDATE,
    DELISTINGDATE,
    DELISTINGINDICATOR,
    EVALUATIONDATE,
    ICUNURSECOUNT,
    MOUREFERENCE,
    MOUSTATUS,
    NABHACCREDITEDINDICATOR,
    NURSETOBEDRATIO,
    NURSETOPATIENTRATIO,
    PROVIDERCATEGORY,
    SERVICESCOPEDESCRIPTION,

    LOAD_DATETIME,
    RECORD_SOURCE

FROM {{ ref('stg2_mp__pd_prop_sp_pv') }}
