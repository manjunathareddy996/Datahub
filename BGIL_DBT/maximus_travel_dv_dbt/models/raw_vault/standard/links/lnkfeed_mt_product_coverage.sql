{{ config(materialized='view') }}
-- FEED for LNK_PRODUCT_COVERAGE: 2 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_product_coverage for the feeders and generators/gen_mt_links_extra.py for the rule.
    select PRODUCT_COVERAGE_HKEY as PRODUCT_COVERAGE_HKEY, PRODUCT_HKEY as PRODUCT_HKEY, COVERAGE_HKEY as COVERAGE_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__product_coverage') }}
    where PRODUCT_COVERAGE_HKEY is not null
