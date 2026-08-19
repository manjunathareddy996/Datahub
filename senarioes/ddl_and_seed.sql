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

-- One seed row (upsert)
MERGE INTO BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_A AS tgt
USING (
    SELECT '1001' AS ID, '7010170101' AS PHONE_1, '2026-01-01 10:00:00'::TIMESTAMP_NTZ AS UPDATED_AT
) AS src
ON tgt.ID = src.ID
WHEN MATCHED THEN UPDATE SET
    tgt.PHONE_1    = src.PHONE_1,
    tgt.UPDATED_AT = src.UPDATED_AT
WHEN NOT MATCHED THEN INSERT (ID, PHONE_1, UPDATED_AT)
    VALUES (src.ID, src.PHONE_1, src.UPDATED_AT);

-- ============================================================================
-- TABLE_B: (id, phone_1, phone_2, updated_at)
-- ============================================================================
CREATE TABLE IF NOT EXISTS BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_B (
    ID              VARCHAR(50),
    PHONE_1         VARCHAR(20),
    PHONE_2         VARCHAR(20),
    UPDATED_AT      TIMESTAMP_NTZ
);

-- One seed row (upsert)
MERGE INTO BAGIC_PREPROD_CURATED_DB.UTILS.TABLE_B AS tgt
USING (
    SELECT '1001' AS ID, '7010170101' AS PHONE_1, '8010180101' AS PHONE_2, '2026-01-05 10:00:00'::TIMESTAMP_NTZ AS UPDATED_AT
) AS src
ON tgt.ID = src.ID
WHEN MATCHED THEN UPDATE SET
    tgt.PHONE_1    = src.PHONE_1,
    tgt.PHONE_2    = src.PHONE_2,
    tgt.UPDATED_AT = src.UPDATED_AT
WHEN NOT MATCHED THEN INSERT (ID, PHONE_1, PHONE_2, UPDATED_AT)
    VALUES (src.ID, src.PHONE_1, src.PHONE_2, src.UPDATED_AT);

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
