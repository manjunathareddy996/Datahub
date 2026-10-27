{{ config(materialized='view') }}

-- LINK LEG vs HUB KEY divergence (decision BD12, open item LEG-KEY-VALUE-DIVERGENCE).
--
-- A link leg must be byte-identical to the key of the hub it references. Where the map
-- gives the leg a different expression, the leg is built AS MAPPED -- substituting the
-- hub's expression would be the build correcting the mapping (BUILD_RULES 5.7).
--
-- The cost of that is SILENT: the leg joins to nothing and reads downstream as sparse
-- source data. orphan_legs > 0 on any row below is that failure, named by link, hub and
-- feeder. Expect zeroes where the leg and the key agree; a zero here is a MEASURED zero.
--
-- 7 value-changing divergences are in the map today, the two that matter being
-- HUB_CLAIM on CLAIM_RESERVE (hub key walks FOREIGN_KEY, leg walks PARENT_KEY_HASH, so
-- the leg rides the UNPROVEN FK round-trip and the hub does not) and the orphan leg
-- 'EMP:' || BAGIC_RM_ECODE, which no HUB_PARTY key anywhere produces.

    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmap_pv' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY__CLAIM_COURT_COUNTERPARTY
    where s.CLAIM_HKEY__CLAIM_COURT_COUNTERPARTY is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__CLAIM_COURT_COUNTERPARTY
    where s.PARTY_HKEY__CLAIM_COURT_COUNTERPARTY is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY__CLAIMANT
    where s.CLAIM_HKEY__CLAIMANT is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__CLAIMANT
    where s.PARTY_HKEY__CLAIMANT is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY__EXPENSE_LINE_PARTY
    where s.CLAIM_HKEY__EXPENSE_LINE_PARTY is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__EXPENSE_LINE_PARTY
    where s.PARTY_HKEY__EXPENSE_LINE_PARTY is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY__PAYEE
    where s.CLAIM_HKEY__PAYEE is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PAYEE
    where s.PARTY_HKEY__PAYEE is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY__EXPENSE_PAYEE
    where s.CLAIM_HKEY__EXPENSE_PAYEE is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__EXPENSE_PAYEE
    where s.PARTY_HKEY__EXPENSE_PAYEE is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY__TDS_DEDUCTEE
    where s.CLAIM_HKEY__TDS_DEDUCTEE is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_rska_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__TDS_DEDUCTEE
    where s.PARTY_HKEY__TDS_DEDUCTEE is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmpay' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmpay') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY__CLAIM_PAYEE
    where s.CLAIM_HKEY__CLAIM_PAYEE is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmpay' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmpay') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__CLAIM_PAYEE
    where s.PARTY_HKEY__CLAIM_PAYEE is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_claim_reserve' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_claim_reserve') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY__V2
    where s.CLAIM_HKEY__V2 is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_claim_reserve' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_claim_reserve') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY
    where s.PARTY_HKEY is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmpty' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmpty') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY
    where s.CLAIM_HKEY is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmpty' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmpty') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY
    where s.PARTY_HKEY is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_CLAIM' as hub, 'clm_clmd_clmrsk_party' as feeder,
           count(*) as legs_emitted,
           count(h.CLAIM_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.CLAIM_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_party') }} s
    left join {{ ref('hub_claim') }} h on h.CLAIM_HKEY = s.CLAIM_HKEY
    where s.CLAIM_HKEY is not null
union all
    select 'LNK_CLAIM_PARTY' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmrsk_party' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_party') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY
    where s.PARTY_HKEY is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'clm_clmd_clmap_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS
    where s.PARTY_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'clm_clmd_clmap_pv' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS
    where s.LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER_CORRESPONDENCE_LOCAL
    where s.PARTY_HKEY__PROPOSER_CORRESPONDENCE_LOCAL is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__PROPOSER_CORRESPONDENCE_LOCAL
    where s.LOCATION_HKEY__PROPOSER_CORRESPONDENCE_LOCAL is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER_PERMANENT_OVERSEAS
    where s.PARTY_HKEY__PROPOSER_PERMANENT_OVERSEAS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__PROPOSER_PERMANENT_OVERSEAS
    where s.LOCATION_HKEY__PROPOSER_PERMANENT_OVERSEAS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pa_address_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pa_address_prop_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER
    where s.PARTY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pa_address_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pa_address_prop_pv') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__INSURED_MEMBER
    where s.LOCATION_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp_pa_address_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pa_address_prop_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER
    where s.PARTY_HKEY__PROPOSER is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'uwr_pol_prp_pa_address_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pa_address_prop_pv') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__PROPOSER
    where s.LOCATION_HKEY__PROPOSER is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL
    where s.PARTY_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL
    where s.LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS
    where s.PARTY_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS
    where s.LOCATION_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pa' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pa') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER_ADDRESS
    where s.PARTY_HKEY__INSURED_MEMBER_ADDRESS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'uwr_pol_ins_mbr_pa' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pa') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__INSURED_MEMBER_ADDRESS
    where s.LOCATION_HKEY__INSURED_MEMBER_ADDRESS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp_pa' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pa') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER_ADDRESS
    where s.PARTY_HKEY__PROPOSER_ADDRESS is not null
union all
    select 'LNK_PARTY_LOCATION' as link, 'HUB_LOCATION' as hub, 'uwr_pol_prp_pa' as feeder,
           count(*) as legs_emitted,
           count(h.LOCATION_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.LOCATION_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pa') }} s
    left join {{ ref('hub_location') }} h on h.LOCATION_HKEY = s.LOCATION_HKEY__PROPOSER_ADDRESS
    where s.LOCATION_HKEY__PROPOSER_ADDRESS is not null
union all
    select 'LNK_PARTY_ROLE' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER
    where s.PARTY_HKEY__PROPOSER is not null
union all
    select 'LNK_PARTY_ROLE' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_rskp_msp_msd_prop_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__NOMINEE
    where s.PARTY_HKEY__NOMINEE is not null
union all
    select 'LNK_PARTY_ROLE' as link, 'HUB_PARTY' as hub, 'uwr_qpd_rskl_msp_imsd_inp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__NOMINEE
    where s.PARTY_HKEY__NOMINEE is not null
union all
    select 'LNK_PARTY_ROLE' as link, 'HUB_PARTY' as hub, 'uwr_pol_polp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__RELATIONSHIP_MANAGER
    where s.PARTY_HKEY__RELATIONSHIP_MANAGER is not null
union all
    select 'LNK_PARTY_ROLE' as link, 'HUB_PARTY' as hub, 'uwr_qpd_polp_rl_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__RELATIONSHIP_MANAGER
    where s.PARTY_HKEY__RELATIONSHIP_MANAGER is not null
union all
    select 'LNK_PARTY_ROLE' as link, 'HUB_PARTY' as hub, 'uwr_pol_polp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__POLICYHOLDER
    where s.PARTY_HKEY__POLICYHOLDER is not null
union all
    select 'LNK_PARTY_ROLE' as link, 'HUB_PARTY' as hub, 'uwr_qpd_polp_rl_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__POLICYHOLDER
    where s.PARTY_HKEY__POLICYHOLDER is not null
union all
    select 'LNK_PARTY_ROLE' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_pp_sp_pv' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER
    where s.PARTY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_ins_mbr_party_relation' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_party_relation') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY__INSURED_MEMBER
    where s.POLICY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_party_relation' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_party_relation') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER
    where s.PARTY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_ins_mbr_party_relation' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_party_relation') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY__INSURED_MEMBER
    where s.POLICY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr_party_relation' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_party_relation') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER
    where s.PARTY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_prp_party_relation' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_party_relation') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY__PROPOSER
    where s.POLICY_HKEY__PROPOSER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp_party_relation' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_party_relation') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER
    where s.PARTY_HKEY__PROPOSER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_prp_party_relation' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_party_relation') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY__PROPOSER
    where s.POLICY_HKEY__PROPOSER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp_party_relation' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp_party_relation') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER
    where s.PARTY_HKEY__PROPOSER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_policy_relation' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_policy_relation') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY
    where s.POLICY_HKEY is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_policy_relation' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_policy_relation') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY
    where s.PARTY_HKEY is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_policy_relation' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_policy_relation') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY
    where s.POLICY_HKEY is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_policy_relation' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_policy_relation') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY
    where s.PARTY_HKEY is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_ins_mbr' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY__INSURED_MEMBER
    where s.POLICY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER
    where s.PARTY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_ins_mbr' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY__INSURED_MEMBER
    where s.POLICY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_ins_mbr' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__INSURED_MEMBER
    where s.PARTY_HKEY__INSURED_MEMBER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_prp' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY__PROPOSER
    where s.POLICY_HKEY__PROPOSER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER
    where s.PARTY_HKEY__PROPOSER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_POLICY' as hub, 'uwr_pol_prp' as feeder,
           count(*) as legs_emitted,
           count(h.POLICY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.POLICY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp') }} s
    left join {{ ref('hub_policy') }} h on h.POLICY_HKEY = s.POLICY_HKEY__PROPOSER
    where s.POLICY_HKEY__PROPOSER is not null
union all
    select 'LNK_POLICY_PARTY' as link, 'HUB_PARTY' as hub, 'uwr_pol_prp' as feeder,
           count(*) as legs_emitted,
           count(h.PARTY_HKEY) as legs_matching_a_hub_row,
           count(*) - count(h.PARTY_HKEY) as orphan_legs
    from {{ ref('stg2_mtv2__uwr_pol_prp') }} s
    left join {{ ref('hub_party') }} h on h.PARTY_HKEY = s.PARTY_HKEY__PROPOSER
    where s.PARTY_HKEY__PROPOSER is not null
