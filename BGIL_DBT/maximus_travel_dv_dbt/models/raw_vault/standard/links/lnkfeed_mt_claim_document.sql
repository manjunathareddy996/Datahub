{{ config(materialized='view') }}
-- FEED for LNK_CLAIM_DOCUMENT: 2 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_claim_document for the feeders and generators/gen_mt_links_extra.py for the rule.
    select CLAIM_DOCUMENT_HKEY as CLAIM_DOCUMENT_HKEY, CLAIM_HKEY as CLAIM_HKEY, DOCUMENT_HKEY as DOCUMENT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__claim_document') }}
    where CLAIM_DOCUMENT_HKEY is not null
