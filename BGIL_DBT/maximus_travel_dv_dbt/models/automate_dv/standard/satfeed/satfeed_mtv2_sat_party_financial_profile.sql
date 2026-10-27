{{ config(materialized='view') }}

-- FEED for SAT_PARTY_FINANCIAL_PROFILE (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 2 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PARTY_FINANCIAL_PROFILE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__CLAIMANT_CUSTOMER as PARTY_HKEY,
        CREDIT_SCORE as CREDIT_SCORE,
        INCOME_SOURCE as INCOME_SOURCE,
        HASHDIFF_PARTY_FINANCIAL_PROFILE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_HKEY__CLAIMANT_CUSTOMER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        CREDIT_SCORE as CREDIT_SCORE,
        INCOME_SOURCE as INCOME_SOURCE,
        HASHDIFF_PARTY_FINANCIAL_PROFILE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_HKEY__PROPOSER is not null
