{{ config(materialized='view') }}

-- FEED for HUB_LOSS_EVENT: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 2 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_LOSS_EVENT|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mtv2_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select LOSS_EVENT_HKEY as LOSS_EVENT_HKEY, LOSS_EVENT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where LOSS_EVENT_BK is not null
union all
    select LOSS_EVENT_HKEY__V2 as LOSS_EVENT_HKEY, LOSS_EVENT_BK__V2 as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where LOSS_EVENT_BK__V2 is not null
