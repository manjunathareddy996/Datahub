{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_SUM_INSURED_BREAKUP: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        SUM_INSURED_HEAD,
        SUM_INSURED_BREAK_UP_DETAIL,
        HASHDIFF_POLICY_SUM_INSURED_BREAKUP as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_cov_covp_sp_pv__sat_aug_policy_sum_insured_breakup') }}
    where POLICY_HKEY is not null
