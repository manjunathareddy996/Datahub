{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_PARTY_CONTACT_ADDRESS_LINK: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS as PARTY_LOCATION_HKEY,
        ADDRESS_USAGE_TYPE,
        ADDRESS_PROOF_EFFECTIVE_DATE,
        SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR,
        SAME_AS_POLICY_ADDRESS_INDICATOR,
        HASHDIFF_PARTY_CONTACT_ADDRESS_LINK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_party_contact_address_link') }}
    where PARTY_LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS is not null
union all
    select
        PARTY_LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL as PARTY_LOCATION_HKEY,
        ADDRESS_USAGE_TYPE,
        ADDRESS_PROOF_EFFECTIVE_DATE,
        SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR,
        SAME_AS_POLICY_ADDRESS_INDICATOR,
        HASHDIFF_PARTY_CONTACT_ADDRESS_LINK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_mbr_pp_sp_pv__sat_aug_party_contact_address_link') }}
    where PARTY_LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL is not null
