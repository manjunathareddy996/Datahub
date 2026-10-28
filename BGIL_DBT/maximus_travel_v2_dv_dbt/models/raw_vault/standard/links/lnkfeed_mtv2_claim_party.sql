{{ config(materialized='view') }}

-- FEED for LNK_CLAIM_PARTY: 10 feeder(s) over 2 hub leg(s).
--
-- Every leg below was rendered by the SAME render_key() as the hub key it references, so
-- a leg and its hub are byte-identical by construction. A disagreeing leg produces an
-- empty join, which reads as sparse source data rather than as an error.

    select CLAIM_PARTY_HKEY__CLAIM_COURT_COUNTERPARTY as CLAIM_PARTY_HKEY, CLAIM_HKEY__CLAIM_COURT_COUNTERPARTY as CLAIM_HKEY, PARTY_HKEY__CLAIM_COURT_COUNTERPARTY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where CLAIM_PARTY_BK__CLAIM_COURT_COUNTERPARTY is not null
union all
    select CLAIM_PARTY_HKEY__CLAIMANT as CLAIM_PARTY_HKEY, CLAIM_HKEY__CLAIMANT as CLAIM_HKEY, PARTY_HKEY__CLAIMANT as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_PARTY_BK__CLAIMANT is not null
union all
    select CLAIM_PARTY_HKEY__EXPENSE_LINE_PARTY as CLAIM_PARTY_HKEY, CLAIM_HKEY__EXPENSE_LINE_PARTY as CLAIM_HKEY, PARTY_HKEY__EXPENSE_LINE_PARTY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_PARTY_BK__EXPENSE_LINE_PARTY is not null
union all
    select CLAIM_PARTY_HKEY__PAYEE as CLAIM_PARTY_HKEY, CLAIM_HKEY__PAYEE as CLAIM_HKEY, PARTY_HKEY__PAYEE as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_PARTY_BK__PAYEE is not null
union all
    select CLAIM_PARTY_HKEY__EXPENSE_PAYEE as CLAIM_PARTY_HKEY, CLAIM_HKEY__EXPENSE_PAYEE as CLAIM_HKEY, PARTY_HKEY__EXPENSE_PAYEE as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_PARTY_BK__EXPENSE_PAYEE is not null
union all
    select CLAIM_PARTY_HKEY__TDS_DEDUCTEE as CLAIM_PARTY_HKEY, CLAIM_HKEY__TDS_DEDUCTEE as CLAIM_HKEY, PARTY_HKEY__TDS_DEDUCTEE as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_PARTY_BK__TDS_DEDUCTEE is not null
union all
    select CLAIM_PARTY_HKEY__CLAIM_PAYEE as CLAIM_PARTY_HKEY, CLAIM_HKEY__CLAIM_PAYEE as CLAIM_HKEY, PARTY_HKEY__CLAIM_PAYEE as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpay') }}
    where CLAIM_PARTY_BK__CLAIM_PAYEE is not null
union all
    select CLAIM_PARTY_HKEY as CLAIM_PARTY_HKEY, CLAIM_HKEY__V2 as CLAIM_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_claim_reserve') }}
    where CLAIM_PARTY_BK is not null
union all
    select CLAIM_PARTY_HKEY as CLAIM_PARTY_HKEY, CLAIM_HKEY as CLAIM_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpty') }}
    where CLAIM_PARTY_BK is not null
union all
    select CLAIM_PARTY_HKEY as CLAIM_PARTY_HKEY, CLAIM_HKEY as CLAIM_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_party') }}
    where CLAIM_PARTY_BK is not null
