{{ config(materialized='view') }}

-- FEED for HUB_LOCATION: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 31 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_LOCATION|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mt_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select LOCATION_HKEY__DOCUMENT_INWARD_ORIGIN_ADDRESS as LOCATION_HKEY, LOCATION_BK__DOCUMENT_INWARD_ORIGIN_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clma_msp_msd_prop_pv') }}
    where LOCATION_BK__DOCUMENT_INWARD_ORIGIN_ADDRESS is not null
union all
    select LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS as LOCATION_HKEY, LOCATION_BK__CLAIMANT_CORRESPONDENCE_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where LOCATION_BK__CLAIMANT_CORRESPONDENCE_ADDRESS is not null
union all
    select LOCATION_HKEY__CLAIM_CORRESPONDENCE_ADDRESS as LOCATION_HKEY, LOCATION_BK__CLAIM_CORRESPONDENCE_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where LOCATION_BK__CLAIM_CORRESPONDENCE_ADDRESS is not null
union all
    select LOCATION_HKEY__CLAIM_LOSS_LOCATION as LOCATION_HKEY, LOCATION_BK__CLAIM_LOSS_LOCATION as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where LOCATION_BK__CLAIM_LOSS_LOCATION is not null
union all
    select LOCATION_HKEY__CLAIM_REFERENCE_ADDRESS as LOCATION_HKEY, LOCATION_BK__CLAIM_REFERENCE_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where LOCATION_BK__CLAIM_REFERENCE_ADDRESS is not null
union all
    select LOCATION_HKEY__CUSTOMER_ANALYTICS_LOCATION as LOCATION_HKEY, LOCATION_BK__CUSTOMER_ANALYTICS_LOCATION as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where LOCATION_BK__CUSTOMER_ANALYTICS_LOCATION is not null
union all
    select LOCATION_HKEY__INSPECTION_ADDRESS as LOCATION_HKEY, LOCATION_BK__INSPECTION_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where LOCATION_BK__INSPECTION_ADDRESS is not null
union all
    select LOCATION_HKEY__STORED_COUNTRY as LOCATION_HKEY, LOCATION_BK__STORED_COUNTRY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where LOCATION_BK__STORED_COUNTRY is not null
union all
    select LOCATION_HKEY__STORED_STATE as LOCATION_HKEY, LOCATION_BK__STORED_STATE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where LOCATION_BK__STORED_STATE is not null
union all
    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmcov_msd_prop_pv') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY__CLAIM_EXPENSE_PARTY_ADDRESS as LOCATION_HKEY, LOCATION_BK__CLAIM_EXPENSE_PARTY_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where LOCATION_BK__CLAIM_EXPENSE_PARTY_ADDRESS is not null
union all
    select LOCATION_HKEY__CLAIM_LOSS_LOCATION as LOCATION_HKEY, LOCATION_BK__CLAIM_LOSS_LOCATION as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where LOCATION_BK__CLAIM_LOSS_LOCATION is not null
union all
    select LOCATION_HKEY__TREATING_HOSPITAL_ADDRESS as LOCATION_HKEY, LOCATION_BK__TREATING_HOSPITAL_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where LOCATION_BK__TREATING_HOSPITAL_ADDRESS is not null
union all
    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_disp') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY__INSURED_MEMBER_ADDRESS as LOCATION_HKEY, LOCATION_BK__INSURED_MEMBER_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa') }}
    where LOCATION_BK__INSURED_MEMBER_ADDRESS is not null
union all
    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa_address_prop_pv') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY__INSURED_MEMBER as LOCATION_HKEY, LOCATION_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa_address_prop_pv') }}
    where LOCATION_BK__INSURED_MEMBER is not null
union all
    select LOCATION_HKEY__CORRESPONDENCE_LOCAL as LOCATION_HKEY, LOCATION_BK__CORRESPONDENCE_LOCAL as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where LOCATION_BK__CORRESPONDENCE_LOCAL is not null
union all
    select LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL as LOCATION_HKEY, LOCATION_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where LOCATION_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL is not null
union all
    select LOCATION_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS as LOCATION_HKEY, LOCATION_BK__INSURED_MEMBER_PERMANENT_OVERSEAS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where LOCATION_BK__INSURED_MEMBER_PERMANENT_OVERSEAS is not null
union all
    select LOCATION_HKEY__PERMANENT_OVERSEAS as LOCATION_HKEY, LOCATION_BK__PERMANENT_OVERSEAS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where LOCATION_BK__PERMANENT_OVERSEAS is not null
union all
    select LOCATION_HKEY__OFFICE_ADDRESS as LOCATION_HKEY, LOCATION_BK__OFFICE_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_off_oa') }}
    where LOCATION_BK__OFFICE_ADDRESS is not null
union all
    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_off_oa_address_prop_pv') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY__PROPOSER_ADDRESS as LOCATION_HKEY, LOCATION_BK__PROPOSER_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pa') }}
    where LOCATION_BK__PROPOSER_ADDRESS is not null
union all
    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pa_address_prop_pv') }}
    where LOCATION_BK is not null
union all
    select LOCATION_HKEY__PROPOSER as LOCATION_HKEY, LOCATION_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pa_address_prop_pv') }}
    where LOCATION_BK__PROPOSER is not null
union all
    select LOCATION_HKEY__CORRESPONDENCE_LOCAL as LOCATION_HKEY, LOCATION_BK__CORRESPONDENCE_LOCAL as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where LOCATION_BK__CORRESPONDENCE_LOCAL is not null
union all
    select LOCATION_HKEY__PERMANENT_OVERSEAS as LOCATION_HKEY, LOCATION_BK__PERMANENT_OVERSEAS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where LOCATION_BK__PERMANENT_OVERSEAS is not null
union all
    select LOCATION_HKEY__PROPOSER_CORRESPONDENCE_LOCAL as LOCATION_HKEY, LOCATION_BK__PROPOSER_CORRESPONDENCE_LOCAL as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where LOCATION_BK__PROPOSER_CORRESPONDENCE_LOCAL is not null
union all
    select LOCATION_HKEY__PROPOSER_PERMANENT_OVERSEAS as LOCATION_HKEY, LOCATION_BK__PROPOSER_PERMANENT_OVERSEAS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where LOCATION_BK__PROPOSER_PERMANENT_OVERSEAS is not null
union all
    select LOCATION_HKEY as LOCATION_HKEY, LOCATION_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl') }}
    where LOCATION_BK is not null
