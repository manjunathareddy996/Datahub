{{ config(materialized='view') }}

-- Feed for HUB_DOCUMENT: renames Maximus's DOCUMENT_BK / DOCUMENT_HKEY to the names
-- partner_dv_dbt already writes (PARENT_BK / DOCUMENT_HKEY), so both projects populate ONE
-- set of columns in the shared table instead of two.

    select DOCUMENT_HKEY as DOCUMENT_HKEY, DOCUMENT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mp__pd_doc') }}
