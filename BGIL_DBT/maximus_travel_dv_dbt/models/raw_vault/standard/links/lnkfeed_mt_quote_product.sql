{{ config(materialized='view', tags=['lnk_extra']) }}
-- FEED for LNK_QUOTE_PRODUCT: 4 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_quote_product for the feeders and generators/gen_mt_links_extra.py for the rule.
    select QUOTE_PRODUCT_HKEY as QUOTE_PRODUCT_HKEY, QUOTE_HKEY as QUOTE_HKEY, PRODUCT_HKEY as PRODUCT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__quote_product') }}
    where QUOTE_PRODUCT_HKEY is not null
