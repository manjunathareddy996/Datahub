{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_DISCOUNT_LOADING_APPLIED: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        ITEM_CODE,
        APPLICABILITY_INDICATOR,
        RELATIVITY_APPLIED,
        RISK_LOADING_TYPE,
        HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_rskp_sp_pv__sat_aug_policy_discount_loading_applied') }}
    where POLICY_HKEY is not null
