{{ config(materialized='view') }}

-- FEED for SAT_LNK_PARTY_ROLE_CORE (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 2 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_LNK_PARTY_ROLE_CORE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        ROLE_CODE as ROLE_CODE,
        ROLE_SEQUENCE as ROLE_SEQUENCE,
        ROLE_TYPE as ROLE_TYPE,
        HASHDIFF_LNK_PARTY_ROLE_CORE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        ROLE_CODE as ROLE_CODE,
        ROLE_SEQUENCE as ROLE_SEQUENCE,
        ROLE_TYPE as ROLE_TYPE,
        HASHDIFF_LNK_PARTY_ROLE_CORE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__uwr_pol_prp_pp_sp_pv__sat_lnk_party_role_core') }}
    where PARTY_HKEY__PROPOSER is not null
