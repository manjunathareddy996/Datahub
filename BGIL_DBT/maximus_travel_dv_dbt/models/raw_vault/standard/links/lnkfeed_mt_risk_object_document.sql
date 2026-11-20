{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_RISK_OBJECT_DOCUMENT: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_risk_object_document for the feeders and generators/gen_mt_links_extra.py for the rule.
    select RISK_OBJECT_DOCUMENT_HKEY as RISK_OBJECT_DOCUMENT_HKEY, RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, DOCUMENT_HKEY as DOCUMENT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__risk_object_document') }}
    where RISK_OBJECT_DOCUMENT_HKEY is not null
