/* =====================================================================================
 test_sat_dup_repro.sql  --  reproduce the sat() tie/duplicate behaviour

 Goal: show that automate_dv.sat() (and the project's sat_multi_source plain branch)
 keeps duplicate / oscillating rows when the staging layer emits more than one row
 per (HKEY, LOAD_DATETIME) because the change-detection LAG window orders ONLY by
 LOAD_DATETIME (no tiebreaker, no src_eff).

 How to use:
   1. STEP A below is the dbt model body. Copy it into a NEW model file you create,
      e.g. opus_partner_dv_dbt/models/raw_vault/.../test_sat.sql  (you said you'll
      create the model file -- this is the body to paste).
   2. STEP B builds a raw staging table in UTILS and loads the duplicate rows.
      Run STEP B in Snowflake first, then `dbt run` the model, then re-run STEP B's
      "second load" block and `dbt run` again to see duplicates accumulate.
   3. STEP C are verification queries to see the duplicates.

 Schema used (adjust db/schema if needed):
   raw stage : BAGIC_PREPROD_CURATED_DB.UTILS.TEST_SAT_STG         (feeds the model)
   satellite : BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.TEST_SAT   (dbt-built)
===================================================================================== */


/* -------------------------------------------------------------------------------------
 STEP A -- dbt MODEL BODY  (paste into the model file you create)
 Model name suggestion: test_sat
 It reads the raw stage view/table and calls automate_dv.sat() exactly like the real
 augmented sats (single payload, NO src_eff -> no tiebreaker, reproduces the bug).
--------------------------------------------------------------------------------------*/
-- {{ config(materialized='incremental', incremental_strategy='append') }}
--
-- {%- set yaml_metadata -%}
-- source_model: 'test_sat_stg'
-- src_pk: 'DOCUMENT_HKEY'
-- src_hashdiff: 'HASHDIFF'
-- src_payload:
--   - 'VERIFICATION_RESPONSE_MESSAGE'
-- src_ldts: 'LOAD_DATETIME'
-- src_source: 'RECORD_SOURCE'
-- {%- endset -%}
--
-- {% set metadata_dict = fromyaml(yaml_metadata) %}
--
-- {{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
--                    src_hashdiff=metadata_dict['src_hashdiff'],
--                    src_payload=metadata_dict['src_payload'],
--                    src_extra_columns=none,
--                    src_eff=none,
--                    src_ldts=metadata_dict['src_ldts'],
--                    src_source=metadata_dict['src_source'],
--                    source_model=metadata_dict['source_model']) }}
--
-- NOTE: you also need a trivial staging model `test_sat_stg` that selects * from the
-- raw stage table below, OR point source_model at a source(). Simplest: create
-- test_sat_stg.sql with:  {{ config(materialized='view') }}  select * from
-- BAGIC_PREPROD_CURATED_DB.UTILS.TEST_SAT_STG


/* -------------------------------------------------------------------------------------
 STEP B -- RAW STAGE + DUPLICATE LOADS   (run in Snowflake)
 HASHDIFF is BINARY(16) = MD5_BINARY of the payload, same as automate_dv.stage().
 Two documents, each with TIE rows (same HKEY + same LOAD_DATETIME, different message)
 and EXACT-duplicate rows (same HKEY + same LOAD_DATETIME + same message).
--------------------------------------------------------------------------------------*/

-- B.1  create the raw stage table (one row per raw verification event)
create or replace table BAGIC_PREPROD_CURATED_DB.UTILS.TEST_SAT_STG (
    DOCUMENT_HKEY                  binary(16),
    HASHDIFF                       binary(16),
    VERIFICATION_RESPONSE_MESSAGE  varchar,
    LOAD_DATETIME                  timestamp_ntz,
    RECORD_SOURCE                  varchar
);

-- helper: HKEY from a document business key, HASHDIFF from the payload (stage() convention)
-- doc A key = 'POI:AAA111'  doc B key = 'POI:BBB222'

-- B.2  FIRST LOAD -- insert rows WITH ties + exact duplicates at the SAME LOAD_DATETIME
insert into BAGIC_PREPROD_CURATED_DB.UTILS.TEST_SAT_STG
    (DOCUMENT_HKEY, HASHDIFF, VERIFICATION_RESPONSE_MESSAGE, LOAD_DATETIME, RECORD_SOURCE)
select
    MD5_BINARY('HUB_DOCUMENT|' || bk)                              as DOCUMENT_HKEY,
    MD5_BINARY(IFNULL(msg, '^^'))                                 as HASHDIFF,
    msg                                                           as VERIFICATION_RESPONSE_MESSAGE,
    ldts::timestamp_ntz                                           as LOAD_DATETIME,
    'OPUS_TEST_POI_DOCUMENT'                                      as RECORD_SOURCE
from values
    -- doc A, same instant, TWO different messages (a TIE) + a repeat of each (EXACT dup)
    ('POI:AAA111', 'Document added successfully in OmniDocs.', '2026-01-01 10:00:00'),
    ('POI:AAA111', NULL,                                       '2026-01-01 10:00:00'),
    ('POI:AAA111', 'Document added successfully in OmniDocs.', '2026-01-01 10:00:00'),  -- exact dup
    ('POI:AAA111', NULL,                                       '2026-01-01 10:00:00'),  -- exact dup
    -- doc A later instant, oscillate back
    ('POI:AAA111', 'Document added successfully in OmniDocs.', '2026-02-01 10:00:00'),
    ('POI:AAA111', NULL,                                       '2026-02-01 10:00:00'),
    -- doc B, single clean row (control -- should NOT duplicate)
    ('POI:BBB222', 'Validate Data class Fail.',               '2026-01-01 10:00:00')
    as t(bk, msg, ldts);

-- >>> now run:  dbt run -s test_sat_stg test_sat
-- (first build is a full load; every surviving change-detection row is inserted)


-- B.3  SECOND LOAD -- same rows again at a NEW instant to show append growth each run
insert into BAGIC_PREPROD_CURATED_DB.UTILS.TEST_SAT_STG
    (DOCUMENT_HKEY, HASHDIFF, VERIFICATION_RESPONSE_MESSAGE, LOAD_DATETIME, RECORD_SOURCE)
select
    MD5_BINARY('HUB_DOCUMENT|' || bk),
    MD5_BINARY(IFNULL(msg, '^^')),
    msg,
    ldts::timestamp_ntz,
    'OPUS_TEST_POI_DOCUMENT'
from values
    ('POI:AAA111', 'Document added successfully in OmniDocs.', '2026-03-01 10:00:00'),
    ('POI:AAA111', NULL,                                       '2026-03-01 10:00:00'),
    ('POI:AAA111', 'Document added successfully in OmniDocs.', '2026-03-01 10:00:00'),  -- exact dup
    ('POI:AAA111', NULL,                                       '2026-03-01 10:00:00')   -- exact dup
    as t(bk, msg, ldts);

-- >>> now run:  dbt run -s test_sat   (incremental append)


/* -------------------------------------------------------------------------------------
 STEP C -- VERIFICATION (run after each dbt run)
--------------------------------------------------------------------------------------*/

-- C.1  rows per (HKEY, LOAD_DATETIME) -- ties/exact dups show count > 1
select to_varchar(DOCUMENT_HKEY,'HEX') as hkey,
       LOAD_DATETIME,
       count(*)                         as rows_at_instant,
       count(distinct HASHDIFF)         as distinct_hashdiffs
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.TEST_SAT
group by 1,2
having count(*) > 1
order by rows_at_instant desc;

-- C.2  full dump to eyeball oscillation + exact duplicates
select to_varchar(DOCUMENT_HKEY,'HEX') as hkey,
       to_varchar(HASHDIFF,'HEX')      as hashdiff,
       VERIFICATION_RESPONSE_MESSAGE,
       LOAD_DATETIME,
       RECORD_SOURCE
from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.TEST_SAT
order by hkey, LOAD_DATETIME, hashdiff;

-- C.3  headline: total rows vs the "correct" count (1 distinct state per key+instant)
select
    (select count(*) from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.TEST_SAT) as actual_rows,
    (select count(*) from (
        select distinct DOCUMENT_HKEY, LOAD_DATETIME, HASHDIFF
        from BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL.TEST_SAT
    )) as deduped_rows;
-- actual_rows > deduped_rows  => exact duplicates present (the bug)
