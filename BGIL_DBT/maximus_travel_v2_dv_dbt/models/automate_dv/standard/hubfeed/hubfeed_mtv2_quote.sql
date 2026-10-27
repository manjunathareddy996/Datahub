{{ config(materialized='view') }}

-- FEED for HUB_QUOTE: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 15 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_QUOTE|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mtv2_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc_rskc_prop') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_qpd_polp_msp_imsd_inp_pv__sat_quote_rating_input') }}
    where QUOTE_BK is not null
union all
    select QUOTE_HKEY as QUOTE_HKEY, QUOTE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_qpd_polp_rl_pv__sat_quote_rating_input') }}
    where QUOTE_BK is not null
