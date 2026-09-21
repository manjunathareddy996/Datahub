{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE'],
        database=var('partner_vault_database', 'BAGIC_PREPROD_CURATED_DB'),
        schema='BGIL_DATA_MODEL',
        tags=['shared_vault_demo']
    )
}}

-- ============================================================================================
-- on_schema_change PROOF -- side B (Maximus). Literal sample data, throwaway table.
--
-- Writes the SAME relation as partner_dv_dbt's model of the same name:
--   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_SAMPLE_PROVIDER
--
-- PARTY_HKEY values PK001..PK003 are identical to Partner's on purpose, so the two sides genuinely
-- collide on the key. RECORD_SOURCE differs, and RECORD_SOURCE is part of the merge unique_key,
-- so the rows coexist as separate versions rather than overwriting each other.
--
-- Column overlap with Partner:
--   shared (5)        PARTY_HKEY, HASHDIFF, EMPANELMENT_DATE, PROVIDER_TYPE, SUPPLIER_ID
--   Maximus-only (3)  MOU_STATUS, NABH_INDICATOR, PROVIDER_CATEGORY   <- appended by dbt
--   Partner-only (2)  EMPANELMENT_STATUS, NETWORK_INDICATOR           <- absent here, must survive
--
-- Run this SECOND. Table goes 9 -> 12 columns, 3 -> 6 rows, and Partner's two exclusive columns
-- keep their original values.
-- ============================================================================================

SELECT
    CAST(PARTY_HKEY        AS VARCHAR)       AS PARTY_HKEY,
    CAST(HASHDIFF          AS VARCHAR)       AS HASHDIFF,
    CAST(EMPANELMENT_DATE  AS VARCHAR)       AS EMPANELMENT_DATE,
    CAST(PROVIDER_TYPE     AS VARCHAR)       AS PROVIDER_TYPE,
    CAST(SUPPLIER_ID       AS VARCHAR)       AS SUPPLIER_ID,
    CAST(MOU_STATUS        AS VARCHAR)       AS MOU_STATUS,
    CAST(NABH_INDICATOR    AS VARCHAR)       AS NABH_INDICATOR,
    CAST(PROVIDER_CATEGORY AS VARCHAR)       AS PROVIDER_CATEGORY,
    CAST(LOAD_DATETIME     AS TIMESTAMP_NTZ) AS LOAD_DATETIME,
    CAST(RECORD_SOURCE     AS VARCHAR)       AS RECORD_SOURCE

FROM VALUES
    ('PK001', 'HM1', '2024-01-10', 'HOSPITAL', 'SUP001', 'SIGNED',  'Y', 'TIER1', '2026-09-15 08:00:00', 'MAXIMUS_SAMPLE'),
    ('PK002', 'HM2', '2024-03-22', 'CLINIC',   'SUP002', 'PENDING', 'N', 'TIER2', '2026-09-15 08:00:00', 'MAXIMUS_SAMPLE'),
    ('PK003', 'HM3', '2023-11-05', 'HOSPITAL', 'SUP003', 'SIGNED',  'Y', 'TIER1', '2026-09-15 08:00:00', 'MAXIMUS_SAMPLE')
    AS t(PARTY_HKEY, HASHDIFF, EMPANELMENT_DATE, PROVIDER_TYPE, SUPPLIER_ID,
         MOU_STATUS, NABH_INDICATOR, PROVIDER_CATEGORY, LOAD_DATETIME, RECORD_SOURCE)
