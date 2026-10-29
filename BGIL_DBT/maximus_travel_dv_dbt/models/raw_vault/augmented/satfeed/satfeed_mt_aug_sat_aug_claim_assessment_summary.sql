{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_ASSESSMENT_SUMMARY: unions 3 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
        AT_FAULT_PARTY_DESCRIPTION,
        LIVE_VIDEO_SURVEY_INDICATOR,
        NON_MEDICAL_ADMISSIBILITY_COMMENTS,
        NON_MEDICAL_ADMISSIBILITY_INDICATOR,
        SAVINGS_AMOUNT,
        SCRUTINY_STATUS,
        SECTION_64VB_PREMIUM_REALISATION_STATUS,
        SPOT_SURVEY_INDICATOR,
        SURVEY_REQUIRED_INDICATOR,
        HASHDIFF_CLAIM_ASSESSMENT_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd__sat_aug_claim_assessment_summary') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
        AT_FAULT_PARTY_DESCRIPTION,
        LIVE_VIDEO_SURVEY_INDICATOR,
        NON_MEDICAL_ADMISSIBILITY_COMMENTS,
        NON_MEDICAL_ADMISSIBILITY_INDICATOR,
        SAVINGS_AMOUNT,
        SCRUTINY_STATUS,
        SECTION_64VB_PREMIUM_REALISATION_STATUS,
        SPOT_SURVEY_INDICATOR,
        SURVEY_REQUIRED_INDICATOR,
        HASHDIFF_CLAIM_ASSESSMENT_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmap_pv__sat_aug_claim_assessment_summary') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        ADVISORY_COMMITTEE_REFERRAL_INDICATOR,
        AT_FAULT_PARTY_DESCRIPTION,
        LIVE_VIDEO_SURVEY_INDICATOR,
        NON_MEDICAL_ADMISSIBILITY_COMMENTS,
        NON_MEDICAL_ADMISSIBILITY_INDICATOR,
        SAVINGS_AMOUNT,
        SCRUTINY_STATUS,
        SECTION_64VB_PREMIUM_REALISATION_STATUS,
        SPOT_SURVEY_INDICATOR,
        SURVEY_REQUIRED_INDICATOR,
        HASHDIFF_CLAIM_ASSESSMENT_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmrsk_rska_properties_pv__sat_aug_claim_assessment_summary') }}
    where CLAIM_HKEY is not null
