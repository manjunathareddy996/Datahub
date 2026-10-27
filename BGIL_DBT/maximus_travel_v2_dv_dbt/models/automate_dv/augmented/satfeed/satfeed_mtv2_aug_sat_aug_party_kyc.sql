{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_PARTY_KYC: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        CKYC_DETAILS_NARRATIVE,
        CKYC_NUMBER_HELD_DECLARED_INDICATOR,
        KYC_DETAILS_DESCRIPTION,
        KYC_DETAIL_DESCRIPTION,
        KYC_RELATED_DETAILS_DESCRIPTION,
        HASHDIFF_PARTY_KYC as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_mbr_pp_sp_pv__sat_aug_party_kyc') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        CKYC_DETAILS_NARRATIVE,
        CKYC_NUMBER_HELD_DECLARED_INDICATOR,
        KYC_DETAILS_DESCRIPTION,
        KYC_DETAIL_DESCRIPTION,
        KYC_RELATED_DETAILS_DESCRIPTION,
        HASHDIFF_PARTY_KYC as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_prp_pp_sp_pv__sat_aug_party_kyc') }}
    where PARTY_HKEY__PROPOSER is not null
