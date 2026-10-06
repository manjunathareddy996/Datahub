-- Reproduce the macro's object build for PANNUMBER exactly, to catch the Duplicate field key.
-- Step 1: source_data (party key + stripped source table + the object value)
-- Step 2: source_deduped  = MAX(value) per (party, source_table)   <-- should make keys unique
-- Step 3: object_rows      = OBJECT_AGG(source_table, value) per party
-- If step 3 throws Duplicate field key, step 2 did not actually make source_table unique.

WITH source_data AS (
    SELECT PARTY_HKEY,
           REGEXP_REPLACE(RECORD_SOURCE, '^OPUS_', '') AS SOURCE_TABLE,
           PANNUMBER
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_m_kyc_pan__party_identification
    UNION ALL
    SELECT PARTY_HKEY, REGEXP_REPLACE(RECORD_SOURCE,'^OPUS_',''), PANNUMBER
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_clm_supp_extn__party_identification
    UNION ALL
    SELECT PARTY_HKEY, REGEXP_REPLACE(RECORD_SOURCE,'^OPUS_',''), PANNUMBER
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_intermediary__party_identification
    UNION ALL
    SELECT PARTY_HKEY, REGEXP_REPLACE(RECORD_SOURCE,'^OPUS_',''), PANNUMBER
    FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification
),
source_deduped AS (
    SELECT PARTY_HKEY, SOURCE_TABLE, MAX(PANNUMBER) AS PANNUMBER
    FROM source_data
    WHERE PARTY_HKEY IS NOT NULL
    GROUP BY PARTY_HKEY, SOURCE_TABLE
)
SELECT PARTY_HKEY,
       OBJECT_AGG(SOURCE_TABLE, TO_VARIANT(PANNUMBER)) AS PANNUMBER
FROM source_deduped
GROUP BY PARTY_HKEY
LIMIT 10;
