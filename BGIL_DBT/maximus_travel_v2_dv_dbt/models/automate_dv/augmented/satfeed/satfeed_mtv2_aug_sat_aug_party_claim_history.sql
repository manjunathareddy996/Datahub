{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_PARTY_CLAIM_HISTORY: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        CLAIM_APPLICANT_DATE_OF_BIRTH,
        CLAIM_APPLICANT_NAME,
        CLAIM_APPLICANT_SALUTATION,
        HASHDIFF_PARTY_CLAIM_HISTORY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_mbr_pp_sp_pv__sat_aug_party_claim_history') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        CLAIM_APPLICANT_DATE_OF_BIRTH,
        CLAIM_APPLICANT_NAME,
        CLAIM_APPLICANT_SALUTATION,
        HASHDIFF_PARTY_CLAIM_HISTORY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_prp_pp_sp_pv__sat_aug_party_claim_history') }}
    where PARTY_HKEY__PROPOSER is not null
