{{ config(materialized='view') }}

-- FEED for HUB_RISK_OBJECT: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 15 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_RISK_OBJECT|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mtv2_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select RISK_OBJECT_HKEY__CLAIMED_RISK_ITEM as RISK_OBJECT_HKEY, RISK_OBJECT_BK__CLAIMED_RISK_ITEM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where RISK_OBJECT_BK__CLAIMED_RISK_ITEM is not null
union all
    select RISK_OBJECT_HKEY__CLAIMED_RISK_ITEM as RISK_OBJECT_HKEY, RISK_OBJECT_BK__CLAIMED_RISK_ITEM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk') }}
    where RISK_OBJECT_BK__CLAIMED_RISK_ITEM is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY__INSURED_RISK_LINE as RISK_OBJECT_HKEY, RISK_OBJECT_BK__INSURED_RISK_LINE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins') }}
    where RISK_OBJECT_BK__INSURED_RISK_LINE is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov_covp_sp_pv') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK as RISK_OBJECT_HKEY, RISK_OBJECT_BK__INSURED_TRAVELLER_RISK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where RISK_OBJECT_BK__INSURED_TRAVELLER_RISK is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY as RISK_OBJECT_HKEY, RISK_OBJECT_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }}
    where RISK_OBJECT_BK is not null
union all
    select RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK as RISK_OBJECT_HKEY, RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }}
    where RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK is not null
