{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        on_schema_change='append_new_columns',
        unique_key=['PARTY_HKEY', 'HASHDIFF', 'RECORD_SOURCE'],
        schema='BGIL_DATA_MODEL',
        tags=['shared_vault_demo']
    )
}}

-- ============================================================================================
-- on_schema_change PROOF -- side A (Partner). Literal sample data, throwaway table.
--
-- Deliberately uses hardcoded rows rather than the real source chain. The live provider data
-- cannot key both systems onto one PARTY_HKEY (Partner hashes the OPUS part_id, Maximus only has
-- supplier_id -- different key spaces), so the real models can never be made to collide on a key.
-- Here the keys are chosen, so the overlap is guaranteed and every count is predictable.
--
-- Target, shared with maximus_partner_dv's model of the same name:
--   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_SAMPLE_PROVIDER
--
-- Run this FIRST. Creates the table with 9 columns, 3 rows.
-- Two of those columns (EMPANELMENT_STATUS, NETWORK_INDICATOR) are Partner-exclusive and must
-- still hold data after the Maximus run -- that is the assertion.
-- ============================================================================================

SELECT
    CAST(PARTY_HKEY          AS VARCHAR)       AS PARTY_HKEY,
    CAST(HASHDIFF            AS VARCHAR)       AS HASHDIFF,
    CAST(EMPANELMENT_DATE    AS VARCHAR)       AS EMPANELMENT_DATE,
    CAST(EMPANELMENT_STATUS  AS VARCHAR)       AS EMPANELMENT_STATUS,
    CAST(NETWORK_INDICATOR   AS VARCHAR)       AS NETWORK_INDICATOR,
    CAST(PROVIDER_TYPE       AS VARCHAR)       AS PROVIDER_TYPE,
    CAST(SUPPLIER_ID         AS VARCHAR)       AS SUPPLIER_ID,
    CAST(LOAD_DATETIME       AS TIMESTAMP_NTZ) AS LOAD_DATETIME,
    CAST(RECORD_SOURCE       AS VARCHAR)       AS RECORD_SOURCE

FROM VALUES
    ('PK001', 'HO1', '2024-01-10', 'ACTIVE',   'Y', 'HOSPITAL', 'SUP001', '2026-09-01 10:00:00', 'OPUS_SAMPLE'),
    ('PK002', 'HO2', '2024-03-22', 'ACTIVE',   'N', 'CLINIC',   'SUP002', '2026-09-01 10:00:00', 'OPUS_SAMPLE'),
    ('PK003', 'HO3', '2023-11-05', 'LAPSED',   'Y', 'HOSPITAL', 'SUP003', '2026-09-01 10:00:00', 'OPUS_SAMPLE')
    AS t(PARTY_HKEY, HASHDIFF, EMPANELMENT_DATE, EMPANELMENT_STATUS, NETWORK_INDICATOR,
         PROVIDER_TYPE, SUPPLIER_ID, LOAD_DATETIME, RECORD_SOURCE)
