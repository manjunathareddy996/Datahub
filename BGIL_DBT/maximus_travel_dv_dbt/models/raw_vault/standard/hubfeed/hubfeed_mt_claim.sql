{{ config(materialized='view') }}

-- FEED for HUB_CLAIM: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 27 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_CLAIM|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mt_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_claim_event_followup') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_claim_history') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_claim_reserve') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY__V2 as CLAIM_HKEY, CLAIM_BK__V2 as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_claim_reserve') }}
    where CLAIM_BK__V2 is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clma_msp_msd_prop_pv') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY__CLAIM_COURT_COUNTERPARTY as CLAIM_HKEY, CLAIM_BK__CLAIM_COURT_COUNTERPARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where CLAIM_BK__CLAIM_COURT_COUNTERPARTY is not null
union all
    select CLAIM_HKEY__LINKED_CLAIM as CLAIM_HKEY, CLAIM_BK__LINKED_CLAIM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where CLAIM_BK__LINKED_CLAIM is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmcov_msd_prop_pv') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpay') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY__CLAIM_PAYEE as CLAIM_HKEY, CLAIM_BK__CLAIM_PAYEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpay') }}
    where CLAIM_BK__CLAIM_PAYEE is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpay_payp_pv') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmpty') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_party') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY__CLAIMANT as CLAIM_HKEY, CLAIM_BK__CLAIMANT as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_BK__CLAIMANT is not null
union all
    select CLAIM_HKEY__EXPENSE_LINE_PARTY as CLAIM_HKEY, CLAIM_BK__EXPENSE_LINE_PARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_BK__EXPENSE_LINE_PARTY is not null
union all
    select CLAIM_HKEY__EXPENSE_PAYEE as CLAIM_HKEY, CLAIM_BK__EXPENSE_PAYEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_BK__EXPENSE_PAYEE is not null
union all
    select CLAIM_HKEY__PAYEE as CLAIM_HKEY, CLAIM_BK__PAYEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_BK__PAYEE is not null
union all
    select CLAIM_HKEY__TDS_DEDUCTEE as CLAIM_HKEY, CLAIM_BK__TDS_DEDUCTEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_BK__TDS_DEDUCTEE is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY__LINKED_BAGGAGE_DELAY_CLAIM as CLAIM_HKEY, CLAIM_BK__LINKED_BAGGAGE_DELAY_CLAIM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where CLAIM_BK__LINKED_BAGGAGE_DELAY_CLAIM is not null
union all
    select CLAIM_HKEY__LINKED_HEALTH_CLAIM as CLAIM_HKEY, CLAIM_BK__LINKED_HEALTH_CLAIM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where CLAIM_BK__LINKED_HEALTH_CLAIM is not null
union all
    select CLAIM_HKEY__LINKED_TRIP_DELAY_CLAIM as CLAIM_HKEY, CLAIM_BK__LINKED_TRIP_DELAY_CLAIM as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where CLAIM_BK__LINKED_TRIP_DELAY_CLAIM is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__clm_clmd_clmap_pv__sat_claim_note') }}
    where CLAIM_BK is not null
union all
    select CLAIM_HKEY as CLAIM_HKEY, CLAIM_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__clm_clmd_clmrsk_rska_properties_pv__sat_claim_note') }}
    where CLAIM_BK is not null
