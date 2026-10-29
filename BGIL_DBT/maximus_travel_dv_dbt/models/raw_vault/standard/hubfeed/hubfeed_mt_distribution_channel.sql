{{ config(materialized='view') }}

-- FEED for HUB_DISTRIBUTION_CHANNEL: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 8 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_DISTRIBUTION_CHANNEL|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mt_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select DISTRIBUTION_CHANNEL_HKEY__DEALER as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK__DEALER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where DISTRIBUTION_CHANNEL_BK__DEALER is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY__INTERMEDIARY as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK__INTERMEDIARY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where DISTRIBUTION_CHANNEL_BK__INTERMEDIARY is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY__V2 as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK__V2 as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where DISTRIBUTION_CHANNEL_BK__V2 is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where DISTRIBUTION_CHANNEL_BK is not null
union all
    select DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY, DISTRIBUTION_CHANNEL_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where DISTRIBUTION_CHANNEL_BK is not null
