{{ config(materialized='view') }}

-- FEED for HUB_COVERAGE: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 8 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_COVERAGE|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mtv2_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select COVERAGE_HKEY as COVERAGE_HKEY, COVERAGE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_properties_pv') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY as COVERAGE_HKEY, COVERAGE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY as COVERAGE_HKEY, COVERAGE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY as COVERAGE_HKEY, COVERAGE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov_covp_sp_pv') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY as COVERAGE_HKEY, COVERAGE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY as COVERAGE_HKEY, COVERAGE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY as COVERAGE_HKEY, COVERAGE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
    where COVERAGE_BK is not null
union all
    select COVERAGE_HKEY as COVERAGE_HKEY, COVERAGE_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }}
    where COVERAGE_BK is not null
