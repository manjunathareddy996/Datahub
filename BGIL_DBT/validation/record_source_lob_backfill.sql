-- =====================================================================
-- RECORD_SOURCE LOB-prefix backfill
-- =====================================================================
-- Context
--   On <date>, the four dbt projects switched RECORD_SOURCE emission from
--   <SYSTEM>_<TABLE>   (e.g. OPUS_BJAZ_INTERMEDIARY)
--   to  <SYSTEM>_<LOB>_<TABLE> (e.g. OPUS_PARTNER_BJAZ_INTERMEDIARY).
--   src_record_source_map values moved from 'OPUS' / 'MAXIMUS' to
--   'OPUS_PARTNER' / 'OPUS_TRAVEL' / 'MAXIMUS_PARTNER' / 'MAXIMUS_TRAVEL'.
--
-- Problem this fixes
--   Every existing row in the shared vault still carries the OLD prefix.
--   The first incremental run after the rename sees no 'OPUS_PARTNER_%' rows
--   so its watermark falls back to 1900-01-01 and reprocesses every source
--   row. Change-detection then inserts new OPUS_PARTNER_<T> rows alongside
--   the legacy OPUS_<T> rows -- same hash key, two RECORD_SOURCE values,
--   duplicate storage. Downstream consumers that pivot/group by
--   RECORD_SOURCE will see split groups.
--
-- What this script does
--   One-time, idempotent, non-destructive UPDATE that rewrites each row's
--   RECORD_SOURCE to the new scheme, based on which project owns it.
--   Mapping is static per project (there is no column that already carries
--   the LOB; the only signal is which project loaded the row, which the old
--   prefix encodes 1:1).
--
--     Old prefix        -> New prefix
--     OPUS_<T>             OPUS_PARTNER_<T>    (every opus_partner row)
--     MAXIMUS_<T>          MAXIMUS_PARTNER_<T> (every maximus_partner row)
--     ... BUT ...
--     Travel rows share the same old tokens as partner rows, so we must
--     split them by the TABLE suffix. Travel rows always carry the view
--     tokens listed in the TRAVEL_TOKENS CTE below; everything else is
--     partner.
--
-- Safety
--   * Transactional; wrap in BEGIN/COMMIT so a partial failure rolls back.
--   * Idempotent: the WHERE clause ignores rows that already carry a
--     LOB-scoped prefix (NOT STARTSWITH ... any of the four new prefixes).
--   * Preview counts section runs read-only so you can see the blast
--     radius before executing.
--   * NO row is deleted. Only RECORD_SOURCE is rewritten.
--
-- Run order
--   1. Preview section        (SELECTs only, read-only)
--   2. Review counts, confirm with the data owner
--   3. Execute section        (BEGIN; UPDATEs; COMMIT;)
--   4. Verification section   (counts after; should match preview expectations)
--
-- Scope
--   Vault schema: BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL
--   Replace with your prod vault location if different.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Config
-- ---------------------------------------------------------------------
SET VAULT_SCHEMA = 'BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL';

-- Travel-side tokens as they appear immediately after the OPUS_ or MAXIMUS_
-- prefix in RECORD_SOURCE. Anything not in this list is partner.
--   Opus travel RECORD_SOURCE values start with 'OPUS_BA_TRV_...',
--   'OPUS_BJAZ_TRV_...' etc.
--   Maximus travel values start with 'MAXIMUS_NONHLTH_TRV_...'.
-- If your project adds more travel view names, extend both arrays.


-- =====================================================================
-- 1. PREVIEW  (read-only; run first, confirm counts before executing)
-- =====================================================================
-- Lists every (table, old-prefix bucket, LOB-classification) and the row
-- count that will be rewritten. Reads INFORMATION_SCHEMA to enumerate
-- every table in the vault that has a RECORD_SOURCE column.

WITH vault_tables AS (
    SELECT table_schema, table_name
    FROM BAGIC_PREPROD_CURATED_DB.INFORMATION_SCHEMA.COLUMNS
    WHERE table_schema = SPLIT_PART($VAULT_SCHEMA, '.', 2)
      AND column_name  = 'RECORD_SOURCE'
    GROUP BY table_schema, table_name
)
SELECT  '-- ' || table_schema || '.' || table_name AS preview_line
FROM    vault_tables
ORDER BY table_name;

-- For a per-table row count of the rewrite candidates, run (one by one or
-- as a batch script) the following templated query against each table.
-- Replace <TABLE> with each name from the list above:

/*
SELECT
    CASE
        WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_PARTNER_')
          OR STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')
          OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_PARTNER_')
          OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')
             THEN 'already_scoped'
        WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
          OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
             THEN 'opus_travel_candidate'
        WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
             THEN 'maximus_travel_candidate'
        WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_')
             THEN 'opus_partner_candidate'
        WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_')
             THEN 'maximus_partner_candidate'
        ELSE 'OTHER_prefix_investigate'
    END                     AS bucket,
    LEFT(RECORD_SOURCE, 40) AS sample_prefix,
    COUNT(*)                AS row_count
FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.<TABLE>
GROUP BY 1, 2
ORDER BY 1, 3 DESC;
*/

-- =====================================================================
-- 2. EXECUTE  (destructive; run only after preview review)
-- =====================================================================
-- One transaction per table so a bad row in one table doesn't abort the
-- rest. If you want all-or-nothing across the whole vault, wrap the
-- entire section in a single BEGIN/COMMIT.
--
-- The UPDATE is driven by RECORD_SOURCE itself:
--   * TRAVEL candidates (view-token-prefixed) get MAXIMUS_TRAVEL_ or
--     OPUS_TRAVEL_ prepended after stripping the bare prefix.
--   * Everything else that still has a bare OPUS_/MAXIMUS_ gets _PARTNER_
--     inserted after the system token.
--
-- Idempotent: rows already starting with a LOB-scoped prefix are skipped.

-- Replace <TABLE> and repeat for every table from the preview list.
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.<TABLE>
   SET RECORD_SOURCE =
       CASE
           -- opus_travel: OPUS_BA_TRV_... / OPUS_BJAZ_TRV_... -> OPUS_TRAVEL_...
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           -- maximus_travel: MAXIMUS_NONHLTH_TRV_... -> MAXIMUS_TRAVEL_...
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           -- opus_partner: OPUS_<other>... -> OPUS_PARTNER_<other>...
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_')
             AND NOT STARTSWITH(RECORD_SOURCE, 'OPUS_PARTNER_')
             AND NOT STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')
                THEN 'OPUS_PARTNER_' || SUBSTR(RECORD_SOURCE, 6)
           -- maximus_partner: MAXIMUS_<other>... -> MAXIMUS_PARTNER_<other>...
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_')
             AND NOT STARTSWITH(RECORD_SOURCE, 'MAXIMUS_PARTNER_')
             AND NOT STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')
                THEN 'MAXIMUS_PARTNER_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE NOT (
           STARTSWITH(RECORD_SOURCE, 'OPUS_PARTNER_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_PARTNER_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')
       );

COMMIT;
*/

-- Composite objects: if any shared sat uses the object branch (grain =
-- one row per (pk, source_group) with RECORD_SOURCE = '<GROUP>_MULTI'),
-- those rows also need rewriting. The CASE above covers that case too
-- because '<GROUP>_MULTI' matches 'OPUS_' / 'MAXIMUS_' prefix branches
-- and the SUBSTR arithmetic is correct.

-- =====================================================================
-- 3. VERIFY  (post-run; should return 0 rows per table)
-- =====================================================================
-- Any row remaining with a bare OPUS_/MAXIMUS_ prefix is a leftover.

/*
SELECT '<TABLE>' AS table_name,
       COUNT(*)  AS unscoped_rows
FROM   BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.<TABLE>
WHERE  (STARTSWITH(RECORD_SOURCE, 'OPUS_')     AND NOT STARTSWITH(RECORD_SOURCE, 'OPUS_PARTNER_')     AND NOT STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_'))
   OR  (STARTSWITH(RECORD_SOURCE, 'MAXIMUS_')  AND NOT STARTSWITH(RECORD_SOURCE, 'MAXIMUS_PARTNER_') AND NOT STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_'));
*/

-- =====================================================================
-- 4. ROLLBACK PLAN  (reference only; destructive)
-- =====================================================================
-- If a run misclassifies rows (e.g. a new travel view token was missed),
-- revert by inverting the CASE: strip the LOB token after the system
-- prefix. Only run after confirming the misclassification scope.
--
-- UPDATE ... SET RECORD_SOURCE =
--   CASE
--     WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_PARTNER_')    THEN 'OPUS_'    || SUBSTR(RECORD_SOURCE, 14)
--     WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'OPUS_'    || SUBSTR(RECORD_SOURCE, 13)
--     WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_PARTNER_') THEN 'MAXIMUS_' || SUBSTR(RECORD_SOURCE, 17)
--     WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'MAXIMUS_' || SUBSTR(RECORD_SOURCE, 16)
--     ELSE RECORD_SOURCE
--   END
-- Not recommended if the new emission scheme is already live, since new
-- loads will keep landing with the LOB prefix.
