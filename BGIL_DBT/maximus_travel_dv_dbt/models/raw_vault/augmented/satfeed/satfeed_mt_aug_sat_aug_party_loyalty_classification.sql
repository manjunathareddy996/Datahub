{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_PARTY_LOYALTY_CLASSIFICATION: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_HKEY__INSURED_CUSTOMER as PARTY_HKEY,
        LOYALTY_CLASSIFICATION_TYPE,
        LOYALTY_BUCKET,
        HASHDIFF_PARTY_LOYALTY_CLASSIFICATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmap_pv__sat_aug_party_loyalty_classification') }}
    where PARTY_HKEY__INSURED_CUSTOMER is not null
