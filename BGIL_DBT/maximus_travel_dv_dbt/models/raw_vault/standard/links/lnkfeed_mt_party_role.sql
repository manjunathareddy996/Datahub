{{ config(materialized='view') }}

-- FEED for LNK_PARTY_ROLE: 8 feeder(s) over 1 hub leg(s) plus 1 degenerate role leg(s).
--
-- Every leg below was rendered by the SAME render_key() as the hub key it references, so
-- a leg and its hub are byte-identical by construction. A disagreeing leg produces an
-- empty join, which reads as sparse source data rather than as an error.
--
-- PARTY_ROLE_ROLE is a role CODE, not a hub key: data_7.js gives LNK_PARTY_ROLE the hub list ['HUB_PARTY']. It is
-- carried here so the link grain is party x role; dropping it would collapse every
-- role a party plays onto one link row (BD5).

    select PARTY_ROLE_HKEY__PROPOSER as PARTY_ROLE_HKEY, PARTY_HKEY__PROPOSER as PARTY_HKEY, cast(null as varchar) as PARTY_ROLE_ROLE,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_ROLE_BK__PROPOSER is not null
union all
    select PARTY_ROLE_HKEY__NOMINEE as PARTY_ROLE_HKEY, PARTY_HKEY__NOMINEE as PARTY_HKEY, PARTY_ROLE_ROLE as PARTY_ROLE_ROLE,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where PARTY_ROLE_BK__NOMINEE is not null
union all
    select PARTY_ROLE_HKEY__NOMINEE as PARTY_ROLE_HKEY, PARTY_HKEY__NOMINEE as PARTY_HKEY, PARTY_ROLE_ROLE as PARTY_ROLE_ROLE,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where PARTY_ROLE_BK__NOMINEE is not null
union all
    select PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER as PARTY_ROLE_HKEY, PARTY_HKEY__RELATIONSHIP_MANAGER as PARTY_HKEY, cast(null as varchar) as PARTY_ROLE_ROLE,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where PARTY_ROLE_BK__RELATIONSHIP_MANAGER is not null
union all
    select PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER as PARTY_ROLE_HKEY, PARTY_HKEY__RELATIONSHIP_MANAGER as PARTY_HKEY, cast(null as varchar) as PARTY_ROLE_ROLE,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where PARTY_ROLE_BK__RELATIONSHIP_MANAGER is not null
union all
    select PARTY_ROLE_HKEY__POLICYHOLDER as PARTY_ROLE_HKEY, PARTY_HKEY__POLICYHOLDER as PARTY_HKEY, PARTY_ROLE_ROLE as PARTY_ROLE_ROLE,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where PARTY_ROLE_BK__POLICYHOLDER is not null
union all
    select PARTY_ROLE_HKEY__POLICYHOLDER as PARTY_ROLE_HKEY, PARTY_HKEY__POLICYHOLDER as PARTY_HKEY, PARTY_ROLE_ROLE as PARTY_ROLE_ROLE,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where PARTY_ROLE_BK__POLICYHOLDER is not null
union all
    select PARTY_ROLE_HKEY__INSURED_MEMBER as PARTY_ROLE_HKEY, PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY, PARTY_ROLE_ROLE as PARTY_ROLE_ROLE,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_ROLE_BK__INSURED_MEMBER is not null
