{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_PREMIUM_HEAD: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        ADJUSTED_INDICATOR,
        COVERAGE_REFERENCE,
        PREMIUM_HEAD_CODE,
        SECTION,
        GROSS_HEAD_PREMIUM,
        HASHDIFF_POLICY_PREMIUM_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_cov__sat_aug_policy_premium_head') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        ADJUSTED_INDICATOR,
        COVERAGE_REFERENCE,
        PREMIUM_HEAD_CODE,
        SECTION,
        GROSS_HEAD_PREMIUM,
        HASHDIFF_POLICY_PREMIUM_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_rskp_sp_pv__sat_aug_policy_premium_head') }}
    where POLICY_HKEY is not null
