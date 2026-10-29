{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_INTERMEDIARY_SPLIT: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        INTERMEDIARY_REFERENCE,
        COMMISSION_CHANGE_EFFECTIVE_DATE,
        SUB_CHANNEL_NAME,
        HASHDIFF_POLICY_INTERMEDIARY_SPLIT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmap_pv__sat_aug_policy_intermediary_split') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        INTERMEDIARY_REFERENCE,
        COMMISSION_CHANGE_EFFECTIVE_DATE,
        SUB_CHANNEL_NAME,
        HASHDIFF_POLICY_INTERMEDIARY_SPLIT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_polp_sp_pv__sat_aug_policy_intermediary_split') }}
    where POLICY_HKEY is not null
