{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_LNK_ROLE_PROVIDER: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_ROLE_HKEY__PROPOSER as PARTY_ROLE_HKEY,
        NATIONAL_TIE_UP_INFORMATION,
        TASK_ALLOCATION_THRESHOLD,
        HASHDIFF_LNK_ROLE_PROVIDER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_prp_pp_sp_pv__sat_aug_lnk_role_provider') }}
    where PARTY_ROLE_HKEY__PROPOSER is not null
