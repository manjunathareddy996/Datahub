{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}

-- INCREMENTAL (APPEND) stg2 for SAT_AGREEMENT_DEFINITION, reading from
-- stg_partner__bjaz_intermediary_incr (the incremental stg table).
--
-- Same pattern as the stg incr model: append-only, watermark derived from
-- MAX(SRC_LOAD_DATE) already in this table. First run = full load, subsequent
-- runs = only rows newer than what's already here.
--
-- This creates a new table:
--   BAGIC_PREPROD_CURATED_DB.BGIL_DEV_DATA_MODEL.STG2_SAT_BJAZ_INTERMEDIARY__AGREEMENT_DEFINITION_INCR
--
-- The existing stg2 view and sat_agreement_definition are untouched.
--
-- Hashing is done inline (same logic as automate_dv.stage() produces) so we
-- don't touch the automate_dv package at all.

WITH staged AS (

    SELECT
        nullif(trim(to_varchar(intermediary_id)), '') AS PARENT_BK,
        'HUB_AGREEMENT|' || nullif(trim(to_varchar(intermediary_id)), '') AS PARENT_NK,
        nullif(trim(to_varchar(nature_of_agreement)), '') AS AGREEMENTTYPE,
        gg_change_date AS SRC_LOAD_DATE,
        CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS LOAD_DATETIME,
        'BJAZ_INTERMEDIARY' AS RECORD_SOURCE
    FROM {{ ref('stg_partner__bjaz_intermediary_incr') }}

),

hashed AS (

    SELECT
        PARENT_BK,
        PARENT_NK,
        AGREEMENTTYPE,
        SRC_LOAD_DATE,
        LOAD_DATETIME,
        RECORD_SOURCE,
        MD5_BINARY(UPPER(TRIM(COALESCE(CAST(PARENT_NK AS VARCHAR), '')))) AS AGREEMENT_HKEY,
        MD5_BINARY(UPPER(TRIM(COALESCE(CAST(AGREEMENTTYPE AS VARCHAR), '')))) AS HASHDIFF
    FROM staged

)

SELECT
    AGREEMENT_HKEY,
    HASHDIFF,
    PARENT_BK,
    PARENT_NK,
    AGREEMENTTYPE,
    SRC_LOAD_DATE,
    LOAD_DATETIME,
    RECORD_SOURCE
FROM hashed
{%- if is_incremental() %}
WHERE SRC_LOAD_DATE > (
          SELECT COALESCE(MAX(SRC_LOAD_DATE), '1900-01-01'::TIMESTAMP_NTZ)
          FROM {{ this }}
      )
{%- endif %}
