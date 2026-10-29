{{ config(materialized='view') }}

-- FEED for SAT_PRODUCT_DEFINITION (target track): unions 7 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 4 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PRODUCT_DEFINITION to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        LINE_OF_BUSINESS as LINE_OF_BUSINESS,
        PRODUCT_CATEGORY as PRODUCT_CATEGORY,
        PRODUCT_NAME as PRODUCT_NAME,
        UIN as UIN,
        HASHDIFF_PRODUCT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where PRODUCT_HKEY is not null
union all
    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        LINE_OF_BUSINESS as LINE_OF_BUSINESS,
        PRODUCT_CATEGORY as PRODUCT_CATEGORY,
        PRODUCT_NAME as PRODUCT_NAME,
        UIN as UIN,
        HASHDIFF_PRODUCT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol') }}
    where PRODUCT_HKEY is not null
union all
    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        LINE_OF_BUSINESS as LINE_OF_BUSINESS,
        PRODUCT_CATEGORY as PRODUCT_CATEGORY,
        PRODUCT_NAME as PRODUCT_NAME,
        UIN as UIN,
        HASHDIFF_PRODUCT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
    where PRODUCT_HKEY is not null
union all
    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        LINE_OF_BUSINESS as LINE_OF_BUSINESS,
        PRODUCT_CATEGORY as PRODUCT_CATEGORY,
        PRODUCT_NAME as PRODUCT_NAME,
        UIN as UIN,
        HASHDIFF_PRODUCT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where PRODUCT_HKEY is not null
union all
    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        LINE_OF_BUSINESS as LINE_OF_BUSINESS,
        PRODUCT_CATEGORY as PRODUCT_CATEGORY,
        PRODUCT_NAME as PRODUCT_NAME,
        UIN as UIN,
        HASHDIFF_PRODUCT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prevpol') }}
    where PRODUCT_HKEY is not null
union all
    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        LINE_OF_BUSINESS as LINE_OF_BUSINESS,
        PRODUCT_CATEGORY as PRODUCT_CATEGORY,
        PRODUCT_NAME as PRODUCT_NAME,
        UIN as UIN,
        HASHDIFF_PRODUCT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where PRODUCT_HKEY is not null
union all
    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        LINE_OF_BUSINESS as LINE_OF_BUSINESS,
        PRODUCT_CATEGORY as PRODUCT_CATEGORY,
        PRODUCT_NAME as PRODUCT_NAME,
        UIN as UIN,
        HASHDIFF_PRODUCT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
    where PRODUCT_HKEY is not null
