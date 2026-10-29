{{ config(materialized='view') }}

-- FEED for SAT_COVERAGE_CONDITIONS (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_COVERAGE_CONDITIONS to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        CONDITION_DESCRIPTION as CONDITION_DESCRIPTION,
        HASHDIFF_COVERAGE_CONDITIONS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_cov_covp_sp_pv') }}
    where COVERAGE_HKEY is not null
union all
    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        CONDITION_DESCRIPTION as CONDITION_DESCRIPTION,
        HASHDIFF_COVERAGE_CONDITIONS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
    where COVERAGE_HKEY is not null
union all
    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        CONDITION_DESCRIPTION as CONDITION_DESCRIPTION,
        HASHDIFF_COVERAGE_CONDITIONS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
    where COVERAGE_HKEY is not null
union all
    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        CONDITION_DESCRIPTION as CONDITION_DESCRIPTION,
        HASHDIFF_COVERAGE_CONDITIONS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
    where COVERAGE_HKEY is not null
