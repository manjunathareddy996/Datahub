{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_COVERAGE_DEFINITION: unions 4 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        COVERAGE_PLAN_VARIANT,
        LEADING_COVER_INDICATOR,
        HASHDIFF_COVERAGE_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_cov_covp_sp_pv__sat_aug_coverage_definition') }}
    where COVERAGE_HKEY is not null
union all
    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        COVERAGE_PLAN_VARIANT,
        LEADING_COVER_INDICATOR,
        HASHDIFF_COVERAGE_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_rskp_sp_pv__sat_aug_coverage_definition') }}
    where COVERAGE_HKEY is not null
union all
    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        COVERAGE_PLAN_VARIANT,
        LEADING_COVER_INDICATOR,
        HASHDIFF_COVERAGE_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_qpd_rskl_rskc_rskc_prop_rl_pv__sat_aug_coverage_definition') }}
    where COVERAGE_HKEY is not null
union all
    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        COVERAGE_PLAN_VARIANT,
        LEADING_COVER_INDICATOR,
        HASHDIFF_COVERAGE_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_qpd_rskl_rskp_rl_pv__sat_aug_coverage_definition') }}
    where COVERAGE_HKEY is not null
