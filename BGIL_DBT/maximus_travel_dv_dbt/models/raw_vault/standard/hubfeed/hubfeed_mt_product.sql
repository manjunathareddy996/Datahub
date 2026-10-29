{{ config(materialized='view') }}

-- FEED for HUB_PRODUCT: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 8 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_PRODUCT|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mt_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prevpol') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where PRODUCT_BK is not null
union all
    select PRODUCT_HKEY as PRODUCT_HKEY, PRODUCT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
    where PRODUCT_BK is not null
