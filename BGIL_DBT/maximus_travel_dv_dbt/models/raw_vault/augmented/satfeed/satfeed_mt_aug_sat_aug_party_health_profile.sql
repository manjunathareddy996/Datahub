{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_PARTY_HEALTH_PROFILE: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        DISABILITY_BODY_LOCATION,
        ICD_DIAGNOSIS_CODE,
        SURGERY_HISTORY_DESCRIPTION,
        HASHDIFF_PARTY_HEALTH_PROFILE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_mbr_pp_sp_pv__sat_aug_party_health_profile') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        DISABILITY_BODY_LOCATION,
        ICD_DIAGNOSIS_CODE,
        SURGERY_HISTORY_DESCRIPTION,
        HASHDIFF_PARTY_HEALTH_PROFILE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_prp_pp_sp_pv__sat_aug_party_health_profile') }}
    where PARTY_HKEY__PROPOSER is not null
