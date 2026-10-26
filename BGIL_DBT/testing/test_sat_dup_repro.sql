/* =====================================================================================
 test_sat_dup_repro.sql  --  reproduce the sat() tie/duplicate behaviour

 Mirrors the REAL structure of sat_aug_kyc_document:
   raw source  BJAZ_T_KYC_POI_DOCUMENT  (many verification events per document)
     -> stg_partner__*          base cast view (reads source(), trims/casts)
        -> stg2_aug_*__document automate_dv.stage() derives DOCUMENT_HKEY / HASHDIFF /
                                 RECORD_SOURCE  (HKEY = HUB_DOCUMENT|docs_type:docs_number,
                                 HASHDIFF over VERIFICATION_RESPONSE_MESSAGE only)
           -> sat               automate_dv.sat()  (change-detection LAG, NO src_eff)

 The duplicates come from the RAW table holding several rows per
 (docs_type, docs_number) at the same INC_JOB_UPDATED_AT -> same (HKEY, LOAD_DATETIME)
 with oscillating / repeated messages. sat()'s LAG window orders only by LOAD_DATETIME
 (no tiebreaker) so ties + exact repeats survive.

 You will create 3 model files (bodies in STEP A1/A2/A3). STEP B seeds the raw table.
 STEP C verifies. db/schema: raw source lives in the schema your source() points at;
 here we seed BAGIC_PREPROD_CURATED_DB.UTILS.TEST_BJAZ_T_KYC_POI_DOCUMENT and reference
 it directly (no sources.yml edit needed).
===================================================================================== */


/* -------------------------------------------------------------------------------------
 STEP A1 -- BASE STAGING MODEL  (paste into stg_partner__test_poi_document.sql)
 Mirrors stg_partner__bjaz_t_kyc_poi_document: cast + trim, read the raw table.
 Only the columns the downstream needs are kept.
--------------------------------------------------------------------------------------*/
-- {{ config(materialized='view') }}
--
-- with source as (
--     select
--         "POI_DOC_ID"::number                         as poi_doc_id,
--         nullif(trim("DOCS_TYPE"::varchar), '')       as docs_type,
--         nullif(trim("DOCS_NUMBER"::varchar), '')     as docs_number,
--         nullif(trim("RESPONSE_MESSAGE"::varchar), '') as response_message,
--         to_timestamp_ntz("INC_JOB_UPDATED_AT"::varchar) as inc_job_updated_at
--     from BAGIC_PREPROD_CURATED_DB.UTILS.TEST_BJAZ_T_KYC_POI_DOCUMENT
-- )
-- select * from source


/* -------------------------------------------------------------------------------------
 STEP A2 -- STG2 STAGE MODEL  (paste into stg2_test_poi_document__document.sql)
 Mirrors stg2_aug_bjaz_t_kyc_poi_document__document: automate_dv.stage() derives the
 hub key and hashdiff EXACTLY like the real model. source_model is the A1 base view.
--------------------------------------------------------------------------------------*/
-- {{ config(materialized='view') }}
--
-- {%- set yaml_metadata -%}
-- source_model: 'stg_partner__test_poi_document'
-- hashed_columns:
--   DOCUMENT_HKEY: 'PARENT_NK'
--   HASHDIFF:
--     is_hashdiff: true
--     columns:
--       - 'VERIFICATION_RESPONSE_MESSAGE'
-- derived_columns:
--   PARENT_BK: "upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,'')))"
--   PARENT_NK: "'HUB_DOCUMENT|' || (upper(trim(coalesce(docs_type,''))) || ':' || upper(trim(coalesce(docs_number,''))))"
--   VERIFICATION_RESPONSE_MESSAGE: 'response_message'
--   LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
--   RECORD_SOURCE: '!OPUS_TEST_POI_DOCUMENT'
-- {%- endset -%}
--
-- {% set metadata_dict = fromyaml(yaml_metadata) %}
--
-- {{ automate_dv.stage(include_source_columns=false,
--                       source_model=metadata_dict['source_model'],
--                       hashed_columns=metadata_dict['hashed_columns'],
--                       derived_columns=metadata_dict['derived_columns']) }}


/* -------------------------------------------------------------------------------------
 STEP A3 -- SATELLITE MODEL  (paste into test_sat.sql)
 Mirrors sat_aug_kyc_document's single-source call: automate_dv.sat(), NO src_eff
 -> no tiebreaker -> reproduces the duplicate/tie behaviour.
--------------------------------------------------------------------------------------*/
-- {{ config(materialized='incremental', incremental_strategy='append') }}
--
-- {%- set yaml_metadata -%}
-- source_model: 'stg2_test_poi_document__document'
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


/* -------------------------------------------------------------------------------------
 STEP B -- RAW SOURCE TABLE + DUPLICATE LOADS   (run in Snowflake)
 Shaped like BJAZ_T_KYC_POI_DOCUMENT (only the columns A1 reads). The raw table holds
 MANY verification events per (docs_type, docs_number) at the same INC_JOB_UPDATED_AT.
--------------------------------------------------------------------------------------*/

-- B.1  create the raw source table
create or replace table BAGIC_PREPROD_CURATED_DB.UTILS.TEST_BJAZ_T_KYC_POI_DOCUMENT (
    POI_DOC_ID          number,
    DOCS_TYPE           varchar,
    DOCS_NUMBER         varchar,
    RESPONSE_MESSAGE    varchar,
    INC_JOB_UPDATED_AT  varchar      -- raw is text; A1 casts to timestamp_ntz
);

-- B.2  FIRST LOAD -- document AAA111 verified several times at the SAME instant
--      (ties: two different messages; exact dups: each message repeated),
--      plus a later instant that oscillates back. BBB222 is a clean control.
insert into BAGIC_PREPROD_CURATED_DB.UTILS.TEST_BJAZ_T_KYC_POI_DOCUMENT
    (POI_DOC_ID, DOCS_TYPE, DOCS_NUMBER, RESPONSE_MESSAGE, INC_JOB_UPDATED_AT)
values
    (1, 'POI', 'AAA111', 'Document added successfully in OmniDocs.', '2026-01-01 10:00:00'),
    (2, 'POI', 'AAA111', NULL,                                       '2026-01-01 10:00:00'),
    (3, 'POI', 'AAA111', 'Document added successfully in OmniDocs.', '2026-01-01 10:00:00'),  -- exact dup
    (4, 'POI', 'AAA111', NULL,                                       '2026-01-01 10:00:00'),  -- exact dup
    (5, 'POI', 'AAA111', 'Document added successfully in OmniDocs.', '2026-02-01 10:00:00'),
    (6, 'POI', 'AAA111', NULL,                                       '2026-02-01 10:00:00'),
    (7, 'POI', 'BBB222', 'Validate Data class Fail.',               '2026-01-01 10:00:00');

-- >>> dbt run -s stg_partner__test_poi_document stg2_test_poi_document__document test_sat


-- B.3  SECOND LOAD -- same oscillating pair at a new instant (append growth each run)
insert into BAGIC_PREPROD_CURATED_DB.UTILS.TEST_BJAZ_T_KYC_POI_DOCUMENT
    (POI_DOC_ID, DOCS_TYPE, DOCS_NUMBER, RESPONSE_MESSAGE, INC_JOB_UPDATED_AT)
values
    (8,  'POI', 'AAA111', 'Document added successfully in OmniDocs.', '2026-03-01 10:00:00'),
    (9,  'POI', 'AAA111', NULL,                                       '2026-03-01 10:00:00'),
    (10, 'POI', 'AAA111', 'Document added successfully in OmniDocs.', '2026-03-01 10:00:00'),  -- exact dup
    (11, 'POI', 'AAA111', NULL,                                       '2026-03-01 10:00:00');  -- exact dup

-- >>> dbt run -s test_sat        (incremental append)


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
