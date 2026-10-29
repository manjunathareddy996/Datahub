{{ config(materialized='view') }}

-- FEED for LNK_POLICY_PARTY: 10 feeder(s) over 2 hub leg(s).
--
-- Every leg below was rendered by the SAME render_key() as the hub key it references, so
-- a leg and its hub are byte-identical by construction. A disagreeing leg produces an
-- empty join, which reads as sparse source data rather than as an error.

    select POLICY_PARTY_HKEY__INSURED_MEMBER as POLICY_PARTY_HKEY, POLICY_HKEY__INSURED_MEMBER as POLICY_HKEY, PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_party_relation') }}
    where POLICY_PARTY_BK__INSURED_MEMBER is not null
union all
    select POLICY_PARTY_HKEY__INSURED_MEMBER as POLICY_PARTY_HKEY, POLICY_HKEY__INSURED_MEMBER as POLICY_HKEY, PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_party_relation') }}
    where POLICY_PARTY_BK__INSURED_MEMBER is not null
union all
    select POLICY_PARTY_HKEY__PROPOSER as POLICY_PARTY_HKEY, POLICY_HKEY__PROPOSER as POLICY_HKEY, PARTY_HKEY__PROPOSER as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_party_relation') }}
    where POLICY_PARTY_BK__PROPOSER is not null
union all
    select POLICY_PARTY_HKEY__PROPOSER as POLICY_PARTY_HKEY, POLICY_HKEY__PROPOSER as POLICY_HKEY, PARTY_HKEY__PROPOSER as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_party_relation') }}
    where POLICY_PARTY_BK__PROPOSER is not null
union all
    select POLICY_PARTY_HKEY as POLICY_PARTY_HKEY, POLICY_HKEY as POLICY_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_policy_relation') }}
    where POLICY_PARTY_BK is not null
union all
    select POLICY_PARTY_HKEY as POLICY_PARTY_HKEY, POLICY_HKEY as POLICY_HKEY, PARTY_HKEY as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_policy_relation') }}
    where POLICY_PARTY_BK is not null
union all
    select POLICY_PARTY_HKEY__INSURED_MEMBER as POLICY_PARTY_HKEY, POLICY_HKEY__INSURED_MEMBER as POLICY_HKEY, PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr') }}
    where POLICY_PARTY_BK__INSURED_MEMBER is not null
union all
    select POLICY_PARTY_HKEY__INSURED_MEMBER as POLICY_PARTY_HKEY, POLICY_HKEY__INSURED_MEMBER as POLICY_HKEY, PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr') }}
    where POLICY_PARTY_BK__INSURED_MEMBER is not null
union all
    select POLICY_PARTY_HKEY__PROPOSER as POLICY_PARTY_HKEY, POLICY_HKEY__PROPOSER as POLICY_HKEY, PARTY_HKEY__PROPOSER as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp') }}
    where POLICY_PARTY_BK__PROPOSER is not null
union all
    select POLICY_PARTY_HKEY__PROPOSER as POLICY_PARTY_HKEY, POLICY_HKEY__PROPOSER as POLICY_HKEY, PARTY_HKEY__PROPOSER as PARTY_HKEY,
           LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp') }}
    where POLICY_PARTY_BK__PROPOSER is not null
