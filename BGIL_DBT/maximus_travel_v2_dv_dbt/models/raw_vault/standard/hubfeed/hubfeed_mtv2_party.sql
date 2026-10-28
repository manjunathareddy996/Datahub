{{ config(materialized='view') }}

-- FEED for HUB_PARTY: unions every INSTANCE of the hub into one key pair and DROPS null
-- business keys. 68 feeder(s).
--
-- The rename to PARENT_BK is the SIBLING's column name, counted from its 226 staging
-- models: both projects populate one set of columns in the shared table rather than two.
-- The NK string hashed upstream is the sibling's too ('HUB_PARTY|' || <business key>); a
-- different NK spelling is a different hash for the same key.
--
-- `where <BK> is not null` is where the key-rejection directive actually bites. A key
-- whose every operand was blank was already turned into NULL by render_key()'s CASE
-- guard, and this is the line that refuses to write it. audit_mtv2_key_rejections
-- counts what this drops, per hub PER FEEDER -- so a zero here is measured, not assumed.

    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_claim_reserve') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS as PARTY_HKEY, PARTY_BK__CLAIMANT_CORRESPONDENCE_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_BK__CLAIMANT_CORRESPONDENCE_ADDRESS is not null
union all
    select PARTY_HKEY__CLAIMANT_CUSTOMER as PARTY_HKEY, PARTY_BK__CLAIMANT_CUSTOMER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_BK__CLAIMANT_CUSTOMER is not null
union all
    select PARTY_HKEY__CLAIM_COURT_COUNTERPARTY as PARTY_HKEY, PARTY_BK__CLAIM_COURT_COUNTERPARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_BK__CLAIM_COURT_COUNTERPARTY is not null
union all
    select PARTY_HKEY__INSURED_CUSTOMER as PARTY_HKEY, PARTY_BK__INSURED_CUSTOMER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_BK__INSURED_CUSTOMER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__SERVICE_PARTNER as PARTY_HKEY, PARTY_BK__SERVICE_PARTNER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_BK__SERVICE_PARTNER is not null
union all
    select PARTY_HKEY__SUB_INTERMEDIARY as PARTY_HKEY, PARTY_BK__SUB_INTERMEDIARY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_BK__SUB_INTERMEDIARY is not null
union all
    select PARTY_HKEY__CLAIM_PAYEE as PARTY_HKEY, PARTY_BK__CLAIM_PAYEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpay') }}
    where PARTY_BK__CLAIM_PAYEE is not null
union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmpty') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_party') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY__CLAIMANT as PARTY_HKEY, PARTY_BK__CLAIMANT as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where PARTY_BK__CLAIMANT is not null
union all
    select PARTY_HKEY__EXPENSE_LINE_PARTY as PARTY_HKEY, PARTY_BK__EXPENSE_LINE_PARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where PARTY_BK__EXPENSE_LINE_PARTY is not null
union all
    select PARTY_HKEY__EXPENSE_PAYEE as PARTY_HKEY, PARTY_BK__EXPENSE_PAYEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where PARTY_BK__EXPENSE_PAYEE is not null
union all
    select PARTY_HKEY__PAYEE as PARTY_HKEY, PARTY_BK__PAYEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where PARTY_BK__PAYEE is not null
union all
    select PARTY_HKEY__TDS_DEDUCTEE as PARTY_HKEY, PARTY_BK__TDS_DEDUCTEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where PARTY_BK__TDS_DEDUCTEE is not null
union all
    select PARTY_HKEY__TREATING_HOSPITAL_PROVIDER as PARTY_HKEY, PARTY_BK__TREATING_HOSPITAL_PROVIDER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_properties_pv') }}
    where PARTY_BK__TREATING_HOSPITAL_PROVIDER is not null
union all
    select PARTY_HKEY__AGENT as PARTY_HKEY, PARTY_BK__AGENT as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol') }}
    where PARTY_BK__AGENT is not null
union all
    select PARTY_HKEY__POLICYHOLDER as PARTY_HKEY, PARTY_BK__POLICYHOLDER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol') }}
    where PARTY_BK__POLICYHOLDER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__PARENT_PARTY as PARTY_HKEY, PARTY_BK__PARENT_PARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr') }}
    where PARTY_BK__PARENT_PARTY is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pa') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER_ADDRESS as PARTY_HKEY, PARTY_BK__INSURED_MEMBER_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pa') }}
    where PARTY_BK__INSURED_MEMBER_ADDRESS is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pa_address_prop_pv') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_party_relation') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_msp_msd_prop_pv') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL as PARTY_HKEY, PARTY_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL is not null
union all
    select PARTY_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS as PARTY_HKEY, PARTY_BK__INSURED_MEMBER_PERMANENT_OVERSEAS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_BK__INSURED_MEMBER_PERMANENT_OVERSEAS is not null
union all
    select PARTY_HKEY__PARENT_PARTY as PARTY_HKEY, PARTY_BK__PARENT_PARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_BK__PARENT_PARTY is not null
union all
    select PARTY_HKEY__NOMINEE as PARTY_HKEY, PARTY_BK__NOMINEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where PARTY_BK__NOMINEE is not null
union all
    select PARTY_HKEY__POLICYHOLDER as PARTY_HKEY, PARTY_BK__POLICYHOLDER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where PARTY_BK__POLICYHOLDER is not null
union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_policy_relation') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY__POLICYHOLDER as PARTY_HKEY, PARTY_BK__POLICYHOLDER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where PARTY_BK__POLICYHOLDER is not null
union all
    select PARTY_HKEY__RELATIONSHIP_MANAGER as PARTY_HKEY, PARTY_BK__RELATIONSHIP_MANAGER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where PARTY_BK__RELATIONSHIP_MANAGER is not null
union all
    select PARTY_HKEY__PARENT_PARTY as PARTY_HKEY, PARTY_BK__PARENT_PARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp') }}
    where PARTY_BK__PARENT_PARTY is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pa') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER_ADDRESS as PARTY_HKEY, PARTY_BK__PROPOSER_ADDRESS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pa') }}
    where PARTY_BK__PROPOSER_ADDRESS is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pa_address_prop_pv') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_party_relation') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_msp_msd_prop_pv') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__BAGIC_EMPLOYEE as PARTY_HKEY, PARTY_BK__BAGIC_EMPLOYEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_BK__BAGIC_EMPLOYEE is not null
union all
    select PARTY_HKEY__PARENT_PARTY as PARTY_HKEY, PARTY_BK__PARENT_PARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_BK__PARENT_PARTY is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER_CORRESPONDENCE_LOCAL as PARTY_HKEY, PARTY_BK__PROPOSER_CORRESPONDENCE_LOCAL as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_BK__PROPOSER_CORRESPONDENCE_LOCAL is not null
union all
    select PARTY_HKEY__PROPOSER_PERMANENT_OVERSEAS as PARTY_HKEY, PARTY_BK__PROPOSER_PERMANENT_OVERSEAS as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_BK__PROPOSER_PERMANENT_OVERSEAS is not null
union all
    select PARTY_HKEY__POLICYHOLDER as PARTY_HKEY, PARTY_BK__POLICYHOLDER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd') }}
    where PARTY_BK__POLICYHOLDER is not null
union all
    select PARTY_HKEY__POLICYHOLDER as PARTY_HKEY, PARTY_BK__POLICYHOLDER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where PARTY_BK__POLICYHOLDER is not null
union all
    select PARTY_HKEY__RELATIONSHIP_MANAGER as PARTY_HKEY, PARTY_BK__RELATIONSHIP_MANAGER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where PARTY_BK__RELATIONSHIP_MANAGER is not null
union all
    select PARTY_HKEY__SUB_INTERMEDIARY as PARTY_HKEY, PARTY_BK__SUB_INTERMEDIARY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where PARTY_BK__SUB_INTERMEDIARY is not null
union all
    select PARTY_HKEY as PARTY_HKEY, PARTY_BK as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl') }}
    where PARTY_BK is not null
union all
    select PARTY_HKEY__ADDITIONAL_PARTY as PARTY_HKEY, PARTY_BK__ADDITIONAL_PARTY as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl') }}
    where PARTY_BK__ADDITIONAL_PARTY is not null
union all
    select PARTY_HKEY__NOMINEE as PARTY_HKEY, PARTY_BK__NOMINEE as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where PARTY_BK__NOMINEE is not null
union all
    select PARTY_HKEY__POLICYHOLDER as PARTY_HKEY, PARTY_BK__POLICYHOLDER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }}
    where PARTY_BK__POLICYHOLDER is not null
union all
    select PARTY_HKEY__CLAIMANT_CUSTOMER as PARTY_HKEY, PARTY_BK__CLAIMANT_CUSTOMER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__clm_clmd_clmap_pv__sat_common_contact') }}
    where PARTY_BK__CLAIMANT_CUSTOMER is not null
union all
    select PARTY_HKEY__CLAIMANT_CUSTOMER as PARTY_HKEY, PARTY_BK__CLAIMANT_CUSTOMER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__clm_clmd_clmap_pv__sat_party_identification') }}
    where PARTY_BK__CLAIMANT_CUSTOMER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_ins_mbr_pa__sat_common_contact') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_ins_mbr_pa_address_prop_pv__sat_common_contact') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_ins_mbr_pp_sp_pv__sat_common_contact') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_ins_mbr_pp_sp_pv__sat_party_identification') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_BK__INSURED_MEMBER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_ins_mbr_pp_sp_pv__sat_party_kyc_reference') }}
    where PARTY_BK__INSURED_MEMBER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_prp_pa__sat_common_contact') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_prp_pa_address_prop_pv__sat_common_contact') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_prp_pp_sp_pv__sat_common_contact') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_prp_pp_sp_pv__sat_lnk_party_role_core') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_prp_pp_sp_pv__sat_party_identification') }}
    where PARTY_BK__PROPOSER is not null
union all
    select PARTY_HKEY__PROPOSER as PARTY_HKEY, PARTY_BK__PROPOSER as PARENT_BK,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_up__uwr_pol_prp_pp_sp_pv__sat_party_kyc_reference') }}
    where PARTY_BK__PROPOSER is not null
