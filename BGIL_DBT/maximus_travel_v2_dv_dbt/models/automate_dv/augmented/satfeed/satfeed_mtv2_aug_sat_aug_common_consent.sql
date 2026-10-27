{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_COMMON_CONSENT: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        DATA_SHARING_CONSENT_INDICATOR,
        HASHDIFF_COMMON_CONSENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_mbr_pp_sp_pv__sat_aug_common_consent') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
