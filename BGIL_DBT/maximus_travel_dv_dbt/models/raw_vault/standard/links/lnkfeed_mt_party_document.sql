{{ config(materialized='view') }}
-- FEED for LNK_PARTY_DOCUMENT: 1 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_party_document for the feeders and generators/gen_mt_links_extra.py for the rule.
    select PARTY_DOCUMENT_HKEY as PARTY_DOCUMENT_HKEY, PARTY_HKEY as PARTY_HKEY, DOCUMENT_HKEY as DOCUMENT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__party_document') }}
    where PARTY_DOCUMENT_HKEY is not null
