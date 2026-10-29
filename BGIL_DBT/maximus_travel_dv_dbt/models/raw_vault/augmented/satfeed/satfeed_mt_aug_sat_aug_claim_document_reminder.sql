{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_DOCUMENT_REMINDER: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        REMINDER_SEQUENCE,
        REQUIREMENT_TYPE_NAME,
        REMINDER_DATE,
        HASHDIFF_CLAIM_DOCUMENT_REMINDER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmcov_msd_prop_pv__sat_aug_claim_document_reminder') }}
    where CLAIM_HKEY is not null
