{{ config(materialized='view') }}

-- FEED for SAT_CLAIM_BENEFIT_HEAD (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 7 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CLAIM_BENEFIT_HEAD to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        BENEFIT_HEAD_CODE as BENEFIT_HEAD_CODE,
        APPROVED_AMOUNT as APPROVED_AMOUNT,
        CLAIMED_AMOUNT as CLAIMED_AMOUNT,
        COVERAGE_REFERENCE as COVERAGE_REFERENCE,
        DEDUCTION_AMOUNT as DEDUCTION_AMOUNT,
        DEDUCTION_REASON as DEDUCTION_REASON,
        HEAD_DESCRIPTION as HEAD_DESCRIPTION,
        SUB_LIMIT_APPLIED as SUB_LIMIT_APPLIED,
        HASHDIFF_CLAIM_BENEFIT_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clma_msp_msd_prop_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        BENEFIT_HEAD_CODE as BENEFIT_HEAD_CODE,
        APPROVED_AMOUNT as APPROVED_AMOUNT,
        CLAIMED_AMOUNT as CLAIMED_AMOUNT,
        COVERAGE_REFERENCE__SAT_CLAIM_BENEFIT_HEAD as COVERAGE_REFERENCE,
        DEDUCTION_AMOUNT as DEDUCTION_AMOUNT,
        DEDUCTION_REASON as DEDUCTION_REASON,
        HEAD_DESCRIPTION as HEAD_DESCRIPTION,
        SUB_LIMIT_APPLIED as SUB_LIMIT_APPLIED,
        HASHDIFF_CLAIM_BENEFIT_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        BENEFIT_HEAD_CODE as BENEFIT_HEAD_CODE,
        APPROVED_AMOUNT as APPROVED_AMOUNT,
        CLAIMED_AMOUNT as CLAIMED_AMOUNT,
        COVERAGE_REFERENCE as COVERAGE_REFERENCE,
        DEDUCTION_AMOUNT as DEDUCTION_AMOUNT,
        DEDUCTION_REASON as DEDUCTION_REASON,
        HEAD_DESCRIPTION as HEAD_DESCRIPTION,
        SUB_LIMIT_APPLIED as SUB_LIMIT_APPLIED,
        HASHDIFF_CLAIM_BENEFIT_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmcov_msd_prop_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        BENEFIT_HEAD_CODE as BENEFIT_HEAD_CODE,
        APPROVED_AMOUNT as APPROVED_AMOUNT,
        CLAIMED_AMOUNT as CLAIMED_AMOUNT,
        COVERAGE_REFERENCE as COVERAGE_REFERENCE,
        DEDUCTION_AMOUNT as DEDUCTION_AMOUNT,
        DEDUCTION_REASON as DEDUCTION_REASON,
        HEAD_DESCRIPTION as HEAD_DESCRIPTION,
        SUB_LIMIT_APPLIED as SUB_LIMIT_APPLIED,
        HASHDIFF_CLAIM_BENEFIT_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where CLAIM_HKEY is not null
