-- ============================================================================
-- DDLs FOR SOURCE TABLES + SEED DATA (run directly in Snowflake)
-- ============================================================================

-- Replace DB/SCHEMA as needed for your environment
-- Using project vars: {{ var('health_test_raw_database') }}.{{ var('health_test_raw_schema') }}

-- ============================================================================
-- TABLE_A: (id, phone_1, updated_at)
-- ============================================================================
CREATE TABLE IF NOT EXISTS BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_A (
    ID              VARCHAR(50),
    PHONE_1         VARCHAR(20),
    UPDATED_AT      TIMESTAMP_NTZ
);

-- One seed row
INSERT INTO BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_A (ID, PHONE_1, UPDATED_AT)
SELECT '1001', '7010170101', '2026-01-01 10:00:00'::TIMESTAMP_NTZ
WHERE NOT EXISTS (
    SELECT 1 FROM BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_A WHERE ID = '1001'
);

-- ============================================================================
-- TABLE_B: (id, phone_1, phone_2, updated_at)
-- ============================================================================
CREATE TABLE IF NOT EXISTS BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_B (
    ID              VARCHAR(50),
    PHONE_1         VARCHAR(20),
    PHONE_2         VARCHAR(20),
    UPDATED_AT      TIMESTAMP_NTZ
);

-- One seed row
INSERT INTO BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_B (ID, PHONE_1, PHONE_2, UPDATED_AT)
SELECT '1001', '7010170101', '8010180101', '2026-01-05 10:00:00'::TIMESTAMP_NTZ
WHERE NOT EXISTS (
    SELECT 1 FROM BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_B WHERE ID = '1001'
);

-- ============================================================================
-- SAT_A_B TARGET TABLE (created by dbt incremental, but DDL for reference)
-- ============================================================================
-- CREATE TABLE IF NOT EXISTS <target_schema>.SAT_A_B (
--     PARTY_HKEY          BINARY(16),
--     HASHDIFF            BINARY(16),
--     PHONE_1             VARCHAR(20),
--     PHONE_2             VARCHAR(20),
--     LOAD_DATETIME       TIMESTAMP_NTZ,
--     RECORD_SOURCE       VARCHAR(100)
-- );
