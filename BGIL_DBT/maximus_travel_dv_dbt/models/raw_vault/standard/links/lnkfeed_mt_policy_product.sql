{{ config(materialized='view') }}
-- FEED for LNK_POLICY_PRODUCT: 2 feeder(s) over 2 hub leg(s). BUILD-SIDE (not in the mapper's map);
-- see lnkbk_mt_policy_product for the feeders and generators/gen_mt_links_extra.py for the rule.
    select POLICY_PRODUCT_HKEY as POLICY_PRODUCT_HKEY, POLICY_HKEY as POLICY_HKEY, PRODUCT_HKEY as PRODUCT_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_lk__policy_product') }}
    where POLICY_PRODUCT_HKEY is not null
