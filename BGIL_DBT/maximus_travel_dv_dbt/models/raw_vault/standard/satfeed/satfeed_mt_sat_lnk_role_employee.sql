{{ config(materialized='view') }}

-- FEED for SAT_LNK_ROLE_EMPLOYEE (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_LNK_ROLE_EMPLOYEE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_ROLE_HKEY__INSURED_MEMBER as PARTY_ROLE_HKEY,
        EMPLOYEE_CODE as EMPLOYEE_CODE,
        HASHDIFF_LNK_ROLE_EMPLOYEE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_ROLE_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER as PARTY_ROLE_HKEY,
        EMPLOYEE_CODE as EMPLOYEE_CODE,
        HASHDIFF_LNK_ROLE_EMPLOYEE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER is not null
union all
    select
        PARTY_ROLE_HKEY__PROPOSER as PARTY_ROLE_HKEY,
        EMPLOYEE_CODE as EMPLOYEE_CODE,
        HASHDIFF_LNK_ROLE_EMPLOYEE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_ROLE_HKEY__PROPOSER is not null
union all
    select
        PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER as PARTY_ROLE_HKEY,
        EMPLOYEE_CODE as EMPLOYEE_CODE,
        HASHDIFF_LNK_ROLE_EMPLOYEE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where PARTY_ROLE_HKEY__RELATIONSHIP_MANAGER is not null
