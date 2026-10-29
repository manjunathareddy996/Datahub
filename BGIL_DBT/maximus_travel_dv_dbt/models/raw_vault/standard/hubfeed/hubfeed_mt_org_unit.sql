{{ config(materialized='view') }}

-- FEED for HUB_ORG_UNIT: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 10 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_ORG_UNIT|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mt_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select ORG_UNIT_HKEY__COMPANY as ORG_UNIT_HKEY, ORG_UNIT_BK__COMPANY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where ORG_UNIT_BK__COMPANY is not null
union all
    select ORG_UNIT_HKEY__OPERATING_HUB as ORG_UNIT_HKEY, ORG_UNIT_BK__OPERATING_HUB as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where ORG_UNIT_BK__OPERATING_HUB is not null
union all
    select ORG_UNIT_HKEY as ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY as ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_off') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY__OFFICE_ADDRESS as ORG_UNIT_HKEY, ORG_UNIT_BK__OFFICE_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_off_oa') }}
    where ORG_UNIT_BK__OFFICE_ADDRESS is not null
union all
    select ORG_UNIT_HKEY as ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_off_oa_address_prop_pv') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY as ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where ORG_UNIT_BK is not null
union all
    select ORG_UNIT_HKEY__SERVICING_BRANCH as ORG_UNIT_HKEY, ORG_UNIT_BK__SERVICING_BRANCH as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where ORG_UNIT_BK__SERVICING_BRANCH is not null
union all
    select ORG_UNIT_HKEY__POLICY_ISSUING_BRANCH as ORG_UNIT_HKEY, ORG_UNIT_BK__POLICY_ISSUING_BRANCH as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where ORG_UNIT_BK__POLICY_ISSUING_BRANCH is not null
union all
    select ORG_UNIT_HKEY as ORG_UNIT_HKEY, ORG_UNIT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where ORG_UNIT_BK is not null
