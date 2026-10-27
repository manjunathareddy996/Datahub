{{ config(materialized='view') }}

-- FEED for HUB_POLICY: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 31 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_POLICY|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mtv2_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY__MASTER_POLICY as POLICY_HKEY, POLICY_BK__MASTER_POLICY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where POLICY_BK__MASTER_POLICY is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_disp') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_endt') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov_covp_sp_pv') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY__INSURED_MEMBER as POLICY_HKEY, POLICY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr') }}
    where POLICY_BK__INSURED_MEMBER is not null
union all
    select POLICY_HKEY__INSURED_MEMBER as POLICY_HKEY, POLICY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_party_relation') }}
    where POLICY_BK__INSURED_MEMBER is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_policy_relation') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY__MASTER_POLICY as POLICY_HKEY, POLICY_BK__MASTER_POLICY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where POLICY_BK__MASTER_POLICY is not null
union all
    select POLICY_HKEY__PREVIOUS_POLICY as POLICY_HKEY, POLICY_BK__PREVIOUS_POLICY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where POLICY_BK__PREVIOUS_POLICY is not null
union all
    select POLICY_HKEY__PREVIOUS_POLICY as POLICY_HKEY, POLICY_BK__PREVIOUS_POLICY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prevpol') }}
    where POLICY_BK__PREVIOUS_POLICY is not null
union all
    select POLICY_HKEY__PROPOSER as POLICY_HKEY, POLICY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp') }}
    where POLICY_BK__PROPOSER is not null
union all
    select POLICY_HKEY__PROPOSER as POLICY_HKEY, POLICY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_party_relation') }}
    where POLICY_BK__PROPOSER is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_wrk') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_prem') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY__MASTER_POLICY as POLICY_HKEY, POLICY_BK__MASTER_POLICY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where POLICY_BK__MASTER_POLICY is not null
union all
    select POLICY_HKEY__PREVIOUS_POLICY as POLICY_HKEY, POLICY_BK__PREVIOUS_POLICY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where POLICY_BK__PREVIOUS_POLICY is not null
union all
    select POLICY_HKEY__PREVIOUS_POLICY_PORTABILITY as POLICY_HKEY, POLICY_BK__PREVIOUS_POLICY_PORTABILITY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where POLICY_BK__PREVIOUS_POLICY_PORTABILITY is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_ins_cov_covp_sp_pv__sat_policy_premium_head') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_ins_rskp_sp_pv__sat_policy_classification') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_ins_rskp_sp_pv__sat_policy_premium_head') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_polp_msp_msd_prop_pv__sat_policy_premium_head') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_polp_sp_pv__sat_policy_classification') }}
    where POLICY_BK is not null
union all
    select POLICY_HKEY as POLICY_HKEY, POLICY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_polp_sp_pv__sat_policy_discount_loading_applied') }}
    where POLICY_BK is not null
