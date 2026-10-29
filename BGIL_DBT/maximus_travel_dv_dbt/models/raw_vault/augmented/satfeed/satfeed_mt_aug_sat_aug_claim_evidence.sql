{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_EVIDENCE: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        SPECIAL_ENCLOSURE_DESCRIPTION,
        SPECIAL_ENCLOSURE_INDICATOR,
        HASHDIFF_CLAIM_EVIDENCE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmap_pv__sat_aug_claim_evidence') }}
    where CLAIM_HKEY is not null
