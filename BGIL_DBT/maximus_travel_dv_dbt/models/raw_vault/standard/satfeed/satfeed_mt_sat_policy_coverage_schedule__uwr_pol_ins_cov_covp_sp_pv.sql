{{ config(materialized='view') }}

-- FEED for SAT_POLICY_COVERAGE_SCHEDULE from stg2_mt__uwr_pol_ins_cov_covp_sp_pv.
-- One satfeed per stage (no UNION) so the sat's per-source watermark and change detection stay intact.
-- Columns and filter are copied unchanged from the former unioned satfeed_mt_sat_policy_coverage_schedule.

    select
        POLICY_HKEY as POLICY_HKEY,
        COVERAGE_REFERENCE as COVERAGE_REFERENCE,
        COVERAGE_SEQUENCE as COVERAGE_SEQUENCE,
        COVERAGE_END_DATE as COVERAGE_END_DATE,
        COVERAGE_OPTED_INDICATOR as COVERAGE_OPTED_INDICATOR,
        COVERAGE_START_DATE as COVERAGE_START_DATE,
        CO_PAYMENT_PERCENTAGE as CO_PAYMENT_PERCENTAGE,
        DEDUCTIBLE_AMOUNT as DEDUCTIBLE_AMOUNT,
        LIMIT_AMOUNT as LIMIT_AMOUNT,
        PREMIUM_FOR_COVERAGE as PREMIUM_FOR_COVERAGE,
        SUM_INSURED as SUM_INSURED,
        HASHDIFF_POLICY_COVERAGE_SCHEDULE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_cov_covp_sp_pv') }}
    where POLICY_HKEY is not null
