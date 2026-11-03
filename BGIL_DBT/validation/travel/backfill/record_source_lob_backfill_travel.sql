-- =====================================================================
-- RECORD_SOURCE LOB-prefix backfill  --  TRAVEL
-- =====================================================================
-- Scope
--   Shared vault BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL. One UPDATE per travel-side table.
--   Rewrites rows whose RECORD_SOURCE still carries the bare prefix
--   (OPUS_BA_TRV_... / OPUS_BJAZ_TRV_... / MAXIMUS_NONHLTH_TRV_...) to
--   the new LOB-scoped prefix:
--
--     OPUS_BA_TRV_<T>       -> OPUS_TRAVEL_BA_TRV_<T>
--     OPUS_BJAZ_TRV_<T>     -> OPUS_TRAVEL_BJAZ_TRV_<T>
--     MAXIMUS_NONHLTH_TRV_<T> -> MAXIMUS_TRAVEL_NONHLTH_TRV_<T>
--
--   Partner-side rows (OPUS_<non-TRV> / MAXIMUS_<non-TRV>) are left
--   untouched by these UPDATEs -- they are handled in a separate
--   backfill file for the partner projects.
--
-- Safety
--   * Each UPDATE is wrapped in its own transaction. If one table fails
--     the rest still succeed.
--   * Idempotent: WHERE clause ignores rows already starting with
--     OPUS_TRAVEL_ or MAXIMUS_TRAVEL_.
--   * NO DELETE. Only RECORD_SOURCE string is rewritten.
--
-- How to use
--   1. Open the PREVIEW block for a table (optional) to see the count.
--   2. Uncomment the BEGIN; UPDATE; COMMIT; block for that table.
--   3. Review the before/after SELECT counts.
--   4. Repeat per table.
--
-- Travel-prefix tokens used in the CASE expression:
--     Opus travel  : OPUS_BA_TRV_, OPUS_BJAZ_TRV_
--     Maximus trv  : MAXIMUS_NONHLTH_TRV_
--   If new travel source tables land with a different prefix, extend
--   the WHEN clauses accordingly.
-- =====================================================================

-- ---------------------------------------------------------------------
-- HUB_AGREEMENT   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_AGREEMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_ASSESSMENT   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ASSESSMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ASSESSMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ASSESSMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_CLAIM   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_CLAIM
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_COVERAGE   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_COVERAGE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_COVERAGE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_COVERAGE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_DISTRIBUTION_CHANNEL   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DISTRIBUTION_CHANNEL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_DOCUMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_DOCUMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_FINANCIAL_ACCOUNT   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_ACCOUNT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_ACCOUNT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_ACCOUNT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_FINANCIAL_TRANSACTION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_TRANSACTION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_TRANSACTION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_FINANCIAL_TRANSACTION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_LOCATION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOCATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_LOSS_EVENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOSS_EVENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOSS_EVENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_LOSS_EVENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_ORG_UNIT   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_ORG_UNIT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_PARTY   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PARTY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_PAYMENT_INSTRUMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PAYMENT_INSTRUMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_POLICY   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_POLICY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_PRODUCT   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PRODUCT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_PROPOSAL   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PROPOSAL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PROPOSAL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_PROPOSAL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_QUOTE   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_QUOTE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_QUOTE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_QUOTE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- HUB_RISK_OBJECT   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.HUB_RISK_OBJECT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- LINK_CLAIM_PARTY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_CLAIM_PARTY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_CLAIM_PARTY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_CLAIM_PARTY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- LINK_PARTY_LOCATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_PARTY_LOCATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_PARTY_LOCATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_PARTY_LOCATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- LINK_PARTY_ROLE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_PARTY_ROLE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_PARTY_ROLE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_PARTY_ROLE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- LINK_POLICY_PARTY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_POLICY_PARTY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_POLICY_PARTY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.LINK_POLICY_PARTY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_ASSESSMENT_HEADER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ASSESSMENT_HEADER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ASSESSMENT_HEADER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ASSESSMENT_HEADER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_APPROVAL_ACTION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_APPROVAL_ACTION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_APPROVAL_ACTION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_APPROVAL_ACTION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_ASSESSMENT_SUMMARY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_ASSESSMENT_SUMMARY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_ASSESSMENT_SUMMARY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_ASSESSMENT_SUMMARY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_BENEFIT_HEAD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_BENEFIT_HEAD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_BENEFIT_HEAD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_BENEFIT_HEAD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_CO_RI_SHARE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_CO_RI_SHARE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_CO_RI_SHARE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_CO_RI_SHARE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_DEDUCTION_WAIVER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DEDUCTION_WAIVER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DEDUCTION_WAIVER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DEDUCTION_WAIVER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_DOCUMENT_REMINDER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DOCUMENT_REMINDER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DOCUMENT_REMINDER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DOCUMENT_REMINDER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_DOCUMENT_REQUIREMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DOCUMENT_REQUIREMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DOCUMENT_REQUIREMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_DOCUMENT_REQUIREMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_EVIDENCE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EVIDENCE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EVIDENCE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EVIDENCE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_EXCLUSION_APPLIED   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EXCLUSION_APPLIED
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EXCLUSION_APPLIED
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EXCLUSION_APPLIED
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_EXPENSE_LINE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EXPENSE_LINE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EXPENSE_LINE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_EXPENSE_LINE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_FOLLOWUP_TASK   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_FOLLOWUP_TASK
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_FOLLOWUP_TASK
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_FOLLOWUP_TASK
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_FRAUD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_FRAUD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_FRAUD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_FRAUD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_HEADER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_HEADER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_HEADER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_HEADER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_LITIGATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_LITIGATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_LITIGATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_LITIGATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_NETWORK_VERIFICATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_NETWORK_VERIFICATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_NETWORK_VERIFICATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_NETWORK_VERIFICATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_PAYMENT_TRANCHE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PAYMENT_TRANCHE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PAYMENT_TRANCHE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PAYMENT_TRANCHE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_PA_DETAIL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PA_DETAIL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PA_DETAIL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PA_DETAIL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_PROVIDER_BILLING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PROVIDER_BILLING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PROVIDER_BILLING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_PROVIDER_BILLING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_QUALITY_AUDIT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_QUALITY_AUDIT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_QUALITY_AUDIT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_QUALITY_AUDIT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_RECOVERY_SALVAGE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_RECOVERY_SALVAGE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_RECOVERY_SALVAGE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_RECOVERY_SALVAGE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_SETTLEMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SETTLEMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SETTLEMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SETTLEMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_SLA_TRACKING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SLA_TRACKING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SLA_TRACKING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SLA_TRACKING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_STATUS_HISTORY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_STATUS_HISTORY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_STATUS_HISTORY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_STATUS_HISTORY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_SURVEY_APPOINTMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SURVEY_APPOINTMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SURVEY_APPOINTMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_SURVEY_APPOINTMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_TPA_INTERACTION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TPA_INTERACTION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TPA_INTERACTION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TPA_INTERACTION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_TRAVEL_DETAIL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TRAVEL_DETAIL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TRAVEL_DETAIL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TRAVEL_DETAIL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_CLAIM_TRAVEL_SECTOR   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TRAVEL_SECTOR
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TRAVEL_SECTOR
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_CLAIM_TRAVEL_SECTOR
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_COMMON_ADDRESS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COMMON_ADDRESS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COMMON_ADDRESS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COMMON_ADDRESS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_COMMON_COMMUNICATION_PREFERENCE   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COMMON_COMMUNICATION_PREFERENCE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COMMON_COMMUNICATION_PREFERENCE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COMMON_COMMUNICATION_PREFERENCE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_COVERAGE_CONDITIONS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_CONDITIONS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_CONDITIONS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_CONDITIONS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_COVERAGE_DEFINITION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_DEFINITION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_DEFINITION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_DEFINITION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_COVERAGE_LIMITS   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_LIMITS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_LIMITS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_LIMITS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_COVERAGE_RATING   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_RATING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_RATING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_RATING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_COVERAGE_SUB_COVER_ELEMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_SUB_COVER_ELEMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_SUB_COVER_ELEMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_COVERAGE_SUB_COVER_ELEMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_DOCUMENT_CHECKLIST   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_CHECKLIST
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_CHECKLIST
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_CHECKLIST
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_DOCUMENT_DISPATCH   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_DISPATCH
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_DISPATCH
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_DISPATCH
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_DOCUMENT_REQUIREMENT_REMINDER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_REQUIREMENT_REMINDER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_REQUIREMENT_REMINDER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_DOCUMENT_REQUIREMENT_REMINDER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_FINTXN_PREMIUM   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FINTXN_PREMIUM
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FINTXN_PREMIUM
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FINTXN_PREMIUM
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_FINTXN_TAX   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FINTXN_TAX
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FINTXN_TAX
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FINTXN_TAX
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_FIN_RECEIPT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FIN_RECEIPT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FIN_RECEIPT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_FIN_RECEIPT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_LNK_PARTY_ROLE_CORE   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_PARTY_ROLE_CORE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_PARTY_ROLE_CORE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_PARTY_ROLE_CORE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_LNK_ROLE_CUSTOMER   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_CUSTOMER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_CUSTOMER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_CUSTOMER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_LNK_ROLE_PROVIDER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_PROVIDER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_PROVIDER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_LNK_ROLE_PROVIDER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_ORG_UNIT_CONTACT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_ORG_UNIT_CONTACT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_ORG_UNIT_CONTACT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_ORG_UNIT_CONTACT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_BANKING   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_BANKING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_BANKING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_BANKING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_CLAIM_HISTORY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CLAIM_HISTORY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CLAIM_HISTORY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CLAIM_HISTORY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_CONSENT_MANDATE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CONSENT_MANDATE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CONSENT_MANDATE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CONSENT_MANDATE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_CONTACT_ADDRESS_LINK   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CONTACT_ADDRESS_LINK
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CONTACT_ADDRESS_LINK
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CONTACT_ADDRESS_LINK
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_CORRESPONDENCE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CORRESPONDENCE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CORRESPONDENCE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_CORRESPONDENCE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_EMPLOYMENT   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_EMPLOYMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_EMPLOYMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_EMPLOYMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_FINANCIAL_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_FINANCIAL_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_FINANCIAL_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_FINANCIAL_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_GROUP_SCHEME   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_GROUP_SCHEME
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_GROUP_SCHEME
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_GROUP_SCHEME
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_HEALTH_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_HEALTH_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_HEALTH_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_HEALTH_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_HIERARCHY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_HIERARCHY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_HIERARCHY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_HIERARCHY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_IDENTIFICATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_IDENTIFICATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_IDENTIFICATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_IDENTIFICATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_IDENTITY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_IDENTITY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_IDENTITY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_IDENTITY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_LOYALTY_CLASSIFICATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_LOYALTY_CLASSIFICATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_LOYALTY_CLASSIFICATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_LOYALTY_CLASSIFICATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_ONBOARDING_JOURNEY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_ONBOARDING_JOURNEY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_ONBOARDING_JOURNEY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_ONBOARDING_JOURNEY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_PAYOUT_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_PAYOUT_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_PAYOUT_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_PAYOUT_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_PREFERENCE_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_PREFERENCE_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_PREFERENCE_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_PREFERENCE_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_RELATIONSHIP_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_RELATIONSHIP_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_RELATIONSHIP_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_RELATIONSHIP_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PARTY_RISK_ANALYTICS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_RISK_ANALYTICS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_RISK_ANALYTICS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PARTY_RISK_ANALYTICS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_CLAIM_EXPERIENCE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_CLAIM_EXPERIENCE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_CLAIM_EXPERIENCE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_CLAIM_EXPERIENCE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_COVERAGE_SCHEDULE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_COVERAGE_SCHEDULE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_COVERAGE_SCHEDULE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_COVERAGE_SCHEDULE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_DELIVERY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_DELIVERY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_DELIVERY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_DELIVERY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_DOCUMENT_DISPATCH   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_DOCUMENT_DISPATCH
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_DOCUMENT_DISPATCH
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_DOCUMENT_DISPATCH
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_HEADER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_HEADER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_HEADER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_HEADER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_HEALTH_DECLARATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_HEALTH_DECLARATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_HEALTH_DECLARATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_HEALTH_DECLARATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_INSURED_DECLARATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_INSURED_DECLARATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_INSURED_DECLARATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_INSURED_DECLARATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_INTERMEDIARY_SPLIT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_INTERMEDIARY_SPLIT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_INTERMEDIARY_SPLIT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_INTERMEDIARY_SPLIT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_NOMINEE_DECLARATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_NOMINEE_DECLARATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_NOMINEE_DECLARATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_NOMINEE_DECLARATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_PREMIUM_HEAD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PREMIUM_HEAD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PREMIUM_HEAD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PREMIUM_HEAD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_PREMIUM_SUMMARY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PREMIUM_SUMMARY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PREMIUM_SUMMARY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PREMIUM_SUMMARY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_PROPERTY_LINE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PROPERTY_LINE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PROPERTY_LINE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_PROPERTY_LINE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_RENEWAL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_RENEWAL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_RENEWAL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_RENEWAL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_TERMS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TERMS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TERMS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TERMS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_TRAVEL_TERMS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TRAVEL_TERMS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TRAVEL_TERMS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TRAVEL_TERMS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_TRAVEL_TRIP_SCHEDULE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TRAVEL_TRIP_SCHEDULE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TRAVEL_TRIP_SCHEDULE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_TRAVEL_TRIP_SCHEDULE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_UW_QUERY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_UW_QUERY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_UW_QUERY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_UW_QUERY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_POLICY_WORK_ITEM   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_WORK_ITEM
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_WORK_ITEM
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_POLICY_WORK_ITEM
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PRODUCT_RATING_STRUCTURE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PRODUCT_RATING_STRUCTURE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PRODUCT_RATING_STRUCTURE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PRODUCT_RATING_STRUCTURE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_PRODUCT_TERMS   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PRODUCT_TERMS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PRODUCT_TERMS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_PRODUCT_TERMS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_CLAIM_EXPERIENCE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_CLAIM_EXPERIENCE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_CLAIM_EXPERIENCE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_CLAIM_EXPERIENCE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_COVERAGE_LINE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVERAGE_LINE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVERAGE_LINE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVERAGE_LINE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_COVERAGE_SCHEDULE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVERAGE_SCHEDULE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVERAGE_SCHEDULE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVERAGE_SCHEDULE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_COVER_DETAIL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVER_DETAIL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVER_DETAIL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_COVER_DETAIL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_HEADER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_HEADER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_HEADER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_HEADER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_HEALTH_DECLARATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_HEALTH_DECLARATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_HEALTH_DECLARATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_HEALTH_DECLARATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_INSURED_DECLARATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_INSURED_DECLARATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_INSURED_DECLARATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_INSURED_DECLARATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_NOMINEE_DECLARATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_NOMINEE_DECLARATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_NOMINEE_DECLARATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_NOMINEE_DECLARATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_PREMIUM_HEAD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_PREMIUM_HEAD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_PREMIUM_HEAD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_PREMIUM_HEAD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_PROPERTY_LINE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_PROPERTY_LINE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_PROPERTY_LINE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_PROPERTY_LINE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_RATING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_RATING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_RATING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_RATING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_RISK_LINE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_RISK_LINE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_RISK_LINE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_RISK_LINE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_SUM_INSURED_BREAKUP   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_SUM_INSURED_BREAKUP
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_SUM_INSURED_BREAKUP
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_SUM_INSURED_BREAKUP
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_TERMS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TERMS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TERMS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TERMS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_TRAVEL_TRIP   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TRAVEL_TRIP
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TRAVEL_TRIP
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TRAVEL_TRIP
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_TRAVEL_TRIP_SCHEDULE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TRAVEL_TRIP_SCHEDULE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TRAVEL_TRIP_SCHEDULE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_TRAVEL_TRIP_SCHEDULE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_QUOTE_UW_QUERY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_UW_QUERY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_UW_QUERY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_QUOTE_UW_QUERY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_RISK_OBJECT_CORE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_OBJECT_CORE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_OBJECT_CORE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_OBJECT_CORE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_RISK_OBJECT_PREMIUM   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_OBJECT_PREMIUM
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_OBJECT_PREMIUM
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_OBJECT_PREMIUM
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_RISK_PERSON_INSURED   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_PERSON_INSURED
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_PERSON_INSURED
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_PERSON_INSURED
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_RISK_PERSON_TRAVEL   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_PERSON_TRAVEL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_PERSON_TRAVEL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_PERSON_TRAVEL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_RISK_TRAVEL_COVER_TERMS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_COVER_TERMS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_COVER_TERMS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_COVER_TERMS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_RISK_TRAVEL_RATING_INPUT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_RATING_INPUT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_RATING_INPUT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_RATING_INPUT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_RISK_TRAVEL_SPONSOR   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_SPONSOR
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_SPONSOR
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_SPONSOR
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_AUG_RISK_TRAVEL_TRIP_ITINERARY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_TRIP_ITINERARY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_TRIP_ITINERARY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_AUG_RISK_TRAVEL_TRIP_ITINERARY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CHANNEL_DEFINITION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_DEFINITION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_DEFINITION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CHANNEL_DEFINITION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_ASSESSMENT_SUMMARY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_ASSESSMENT_SUMMARY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_ASSESSMENT_SUMMARY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_ASSESSMENT_SUMMARY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_BENEFIT_HEAD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_BENEFIT_HEAD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_BENEFIT_HEAD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_BENEFIT_HEAD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_CO_RI_SHARE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_CO_RI_SHARE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_CO_RI_SHARE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_CO_RI_SHARE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_FNOL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FNOL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FNOL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FNOL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_FRAUD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FRAUD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FRAUD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_FRAUD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_HEADER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_HEADER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_HEADER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_HEADER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_HEALTH_DETAIL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_HEALTH_DETAIL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_HEALTH_DETAIL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_HEALTH_DETAIL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_INVESTIGATION_FINDING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_INVESTIGATION_FINDING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_INVESTIGATION_FINDING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_INVESTIGATION_FINDING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_LITIGATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_LITIGATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_LITIGATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_LITIGATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_NOTE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_NOTE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_NOTE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_NOTE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_PAYMENT_TRANCHE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PAYMENT_TRANCHE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PAYMENT_TRANCHE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PAYMENT_TRANCHE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_PA_DETAIL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PA_DETAIL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PA_DETAIL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PA_DETAIL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_PROVIDER_BILLING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PROVIDER_BILLING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PROVIDER_BILLING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_PROVIDER_BILLING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_RECOVERY_SALVAGE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RECOVERY_SALVAGE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RECOVERY_SALVAGE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RECOVERY_SALVAGE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_REPUDIATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_REPUDIATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_REPUDIATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_REPUDIATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_RESERVE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RESERVE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RESERVE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RESERVE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_RESERVE_HEAD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RESERVE_HEAD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RESERVE_HEAD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_RESERVE_HEAD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_SETTLEMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SETTLEMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SETTLEMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SETTLEMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_SLA_TRACKING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SLA_TRACKING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SLA_TRACKING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_SLA_TRACKING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_TP_FORENSIC   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_TP_FORENSIC
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_TP_FORENSIC
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_TP_FORENSIC
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_CLAIM_TRAVEL_DETAIL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_TRAVEL_DETAIL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_TRAVEL_DETAIL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_CLAIM_TRAVEL_DETAIL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_ADDRESS   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADDRESS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADDRESS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADDRESS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_ADMIN_GEOGRAPHY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADMIN_GEOGRAPHY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADMIN_GEOGRAPHY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_ADMIN_GEOGRAPHY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_BUSINESS_AUDIT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_BUSINESS_AUDIT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_BUSINESS_AUDIT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_BUSINESS_AUDIT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_CLASSIFICATION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CLASSIFICATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CLASSIFICATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CLASSIFICATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_COMMUNICATION_PREFERENCE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_COMMUNICATION_PREFERENCE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_COMMUNICATION_PREFERENCE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_COMMUNICATION_PREFERENCE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_CONSENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONSENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONSENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONSENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_CONTACT   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_CONTACT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_GEO   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_GEO
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_GEO
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_GEO
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_LIFECYCLE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_LIFECYCLE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_LIFECYCLE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_LIFECYCLE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_MONETARY_CONTEXT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_MONETARY_CONTEXT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_MONETARY_CONTEXT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_MONETARY_CONTEXT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COMMON_STATUS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_STATUS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_STATUS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COMMON_STATUS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COVERAGE_CONDITIONS   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_CONDITIONS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_CONDITIONS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_CONDITIONS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COVERAGE_DEFINITION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_DEFINITION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_DEFINITION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_DEFINITION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COVERAGE_LIMITS   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_LIMITS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_LIMITS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_LIMITS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_COVERAGE_SUBLIMIT_SCHEDULE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_SUBLIMIT_SCHEDULE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_SUBLIMIT_SCHEDULE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_COVERAGE_SUBLIMIT_SCHEDULE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_DOCUMENT_DEFINITION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_DOCUMENT_DEFINITION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_DOCUMENT_DEFINITION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_DOCUMENT_DEFINITION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_FINTXN_ACCOUNTING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_ACCOUNTING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_ACCOUNTING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_ACCOUNTING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_FINTXN_CLAIM_PAYMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_CLAIM_PAYMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_CLAIM_PAYMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_CLAIM_PAYMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_FINTXN_COMMISSION   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_COMMISSION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_COMMISSION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_COMMISSION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_FINTXN_HEADER   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_HEADER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_HEADER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_HEADER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_FINTXN_PREMIUM   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_PREMIUM
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_PREMIUM
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_PREMIUM
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_FINTXN_TAX   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_TAX
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_TAX
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FINTXN_TAX
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_FIN_CHARGE_RATE   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_CHARGE_RATE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_CHARGE_RATE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_CHARGE_RATE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_FIN_RECEIPT   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_RECEIPT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_RECEIPT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_FIN_RECEIPT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_INSTRUMENT_DEFINITION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_INSTRUMENT_DEFINITION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_INSTRUMENT_DEFINITION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_INSTRUMENT_DEFINITION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LNK_PARTY_ROLE_CORE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_PARTY_ROLE_CORE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_PARTY_ROLE_CORE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_PARTY_ROLE_CORE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LNK_POLICY_PARTY_ROLE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_POLICY_PARTY_ROLE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_POLICY_PARTY_ROLE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_POLICY_PARTY_ROLE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LNK_ROLE_AGENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_AGENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_AGENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_AGENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LNK_ROLE_CUSTOMER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_CUSTOMER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_CUSTOMER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_CUSTOMER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LNK_ROLE_EMPLOYEE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_EMPLOYEE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_EMPLOYEE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_EMPLOYEE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LNK_ROLE_NOMINEE_BENEFICIARY   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_NOMINEE_BENEFICIARY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_NOMINEE_BENEFICIARY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LNK_ROLE_NOMINEE_BENEFICIARY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LOSS_EVENT_DETAIL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_EVENT_DETAIL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_EVENT_DETAIL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_EVENT_DETAIL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LOSS_EVENT_NOTIFICATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_EVENT_NOTIFICATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_EVENT_NOTIFICATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_EVENT_NOTIFICATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_LOSS_LOCATION_ADDRESS   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_LOCATION_ADDRESS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_LOCATION_ADDRESS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_LOSS_LOCATION_ADDRESS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_ORG_UNIT_DEFINITION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ORG_UNIT_DEFINITION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ORG_UNIT_DEFINITION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_ORG_UNIT_DEFINITION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_AML_SCREENING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_AML_SCREENING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_AML_SCREENING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_AML_SCREENING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_BANKING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_BANKING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_BANKING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_BANKING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_CLAIM_HISTORY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CLAIM_HISTORY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CLAIM_HISTORY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CLAIM_HISTORY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_CONTACT_ADDRESS_LINK   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CONTACT_ADDRESS_LINK
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CONTACT_ADDRESS_LINK
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_CONTACT_ADDRESS_LINK
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_EMPLOYMENT   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_EMPLOYMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_EMPLOYMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_EMPLOYMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_FINANCIAL_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_FINANCIAL_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_FINANCIAL_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_FINANCIAL_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_FRAUD_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_FRAUD_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_FRAUD_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_FRAUD_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_HEALTH_PROFILE   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_HEALTH_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_HEALTH_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_HEALTH_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_IDENTIFICATION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTIFICATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_IDENTITY   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_IDENTITY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_KYC   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_KYC_REFERENCE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC_REFERENCE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC_REFERENCE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_KYC_REFERENCE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_ONBOARDING_JOURNEY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_ONBOARDING_JOURNEY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_ONBOARDING_JOURNEY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_ONBOARDING_JOURNEY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_ORGANISATION_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_ORGANISATION_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_ORGANISATION_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_ORGANISATION_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_PAYOUT_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_PAYOUT_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_PAYOUT_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_PAYOUT_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_POLICY_HISTORY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_POLICY_HISTORY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_POLICY_HISTORY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_POLICY_HISTORY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_PORTFOLIO_SUMMARY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_PORTFOLIO_SUMMARY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_PORTFOLIO_SUMMARY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_PORTFOLIO_SUMMARY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PARTY_RELATIONSHIP_PROFILE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_RELATIONSHIP_PROFILE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_RELATIONSHIP_PROFILE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PARTY_RELATIONSHIP_PROFILE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_CANCELLATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CANCELLATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CANCELLATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CANCELLATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_CLASSIFICATION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CLASSIFICATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CLASSIFICATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_CLASSIFICATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_COVERAGE_SCHEDULE   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_COVERAGE_SCHEDULE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_COVERAGE_SCHEDULE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_COVERAGE_SCHEDULE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_DISCOUNT_LOADING_APPLIED   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DISCOUNT_LOADING_APPLIED
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DISCOUNT_LOADING_APPLIED
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_DISCOUNT_LOADING_APPLIED
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_ENDORSEMENT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_ENDORSEMENT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_ENDORSEMENT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_ENDORSEMENT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_GROUP   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_GROUP
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_GROUP
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_GROUP
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_HEADER   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_HEADER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_INTERMEDIARY_SPLIT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_INTERMEDIARY_SPLIT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_INTERMEDIARY_SPLIT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_INTERMEDIARY_SPLIT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_PORTABILITY_MIGRATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PORTABILITY_MIGRATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PORTABILITY_MIGRATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PORTABILITY_MIGRATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_PREMIUM_HEAD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_HEAD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_HEAD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_HEAD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_PREMIUM_SUMMARY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_SUMMARY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_SUMMARY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_PREMIUM_SUMMARY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_RENEWAL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_RENEWAL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_RENEWAL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_RENEWAL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_SERVICING_SUMMARY   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_SERVICING_SUMMARY
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_SERVICING_SUMMARY
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_SERVICING_SUMMARY
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_SUM_INSURED_BREAKUP   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_SUM_INSURED_BREAKUP
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_SUM_INSURED_BREAKUP
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_SUM_INSURED_BREAKUP
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_TAX_BREAKUP   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_BREAKUP
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_BREAKUP
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_BREAKUP
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_TAX_HEAD   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_HEAD
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_HEAD
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TAX_HEAD
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_POLICY_TERMS   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TERMS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TERMS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_POLICY_TERMS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PRODUCT_DEFINITION   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DEFINITION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DEFINITION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_DEFINITION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PRODUCT_RATING_FACTOR   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RATING_FACTOR
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RATING_FACTOR
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RATING_FACTOR
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PRODUCT_RATING_STRUCTURE   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RATING_STRUCTURE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RATING_STRUCTURE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_RATING_STRUCTURE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PRODUCT_TERMS   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_TERMS
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_TERMS
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PRODUCT_TERMS
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_PROPOSAL_UNDERWRITING   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_UNDERWRITING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_UNDERWRITING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_PROPOSAL_UNDERWRITING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_QUOTE_HEADER   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_HEADER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_HEADER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_HEADER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_QUOTE_RATING   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_QUOTE_RATING_INPUT   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING_INPUT
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING_INPUT
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_QUOTE_RATING_INPUT
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_RISK_HEALTH_MEMBER_MEDICAL   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_HEALTH_MEMBER_MEDICAL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_HEALTH_MEMBER_MEDICAL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_HEALTH_MEMBER_MEDICAL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_RISK_MOTOR_DRIVER   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_DRIVER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_DRIVER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_DRIVER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_RISK_MOTOR_VEHICLE   (opus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_VEHICLE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_VEHICLE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_MOTOR_VEHICLE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_RISK_OBJECT_CORE   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_CORE
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_CORE
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_CORE
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_RISK_OBJECT_VALUATION   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_VALUATION
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_VALUATION
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_OBJECT_VALUATION
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_RISK_PERSON_INSURED   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_INSURED
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_INSURED
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_INSURED
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_RISK_PERSON_MEMBER   (maximus_travel only)
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_MEMBER
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_MEMBER
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_MEMBER
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/

-- ---------------------------------------------------------------------
-- SAT_RISK_PERSON_TRAVEL   (shared (opus_travel + maximus_travel))
-- ---------------------------------------------------------------------

-- Preview (read-only):
/*
SELECT CASE
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_TRAVEL_')     THEN 'already_opus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_TRAVEL_')  THEN 'already_maximus_travel'
         WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
           OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')   THEN 'opus_travel_candidate'
         WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_') THEN 'maximus_travel_candidate'
         ELSE 'other_leave_as_is'
       END AS bucket,
       COUNT(*) AS row_count
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_TRAVEL
 GROUP BY 1
 ORDER BY 2 DESC;
*/

-- Execute (destructive; uncomment to run):
/*
BEGIN;

UPDATE BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_TRAVEL
   SET RECORD_SOURCE =
       CASE
           WHEN STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
             OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
                THEN 'OPUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 6)
           WHEN STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
                THEN 'MAXIMUS_TRAVEL_' || SUBSTR(RECORD_SOURCE, 9)
           ELSE RECORD_SOURCE
       END
 WHERE (
           STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
        OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_')
       );

COMMIT;
*/

-- Verify after run (should return 0):
/*
SELECT COUNT(*) AS unscoped_travel_rows
  FROM BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.SAT_RISK_PERSON_TRAVEL
 WHERE STARTSWITH(RECORD_SOURCE, 'OPUS_BA_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'OPUS_BJAZ_TRV_')
    OR STARTSWITH(RECORD_SOURCE, 'MAXIMUS_NONHLTH_TRV_');
*/
