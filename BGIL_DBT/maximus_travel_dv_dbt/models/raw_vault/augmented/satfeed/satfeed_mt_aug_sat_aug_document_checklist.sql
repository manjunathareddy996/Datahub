{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_DOCUMENT_CHECKLIST: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET as DOCUMENT_HKEY,
        REQUIRED_DOCUMENT_TYPE,
        REQUIREMENT_RESPONSE_TEXT,
        REQUIREMENT_SOUGHT_FROM,
        REQUIREMENT_STATUS,
        HASHDIFF_DOCUMENT_CHECKLIST as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clma_msp_msd_prop_pv__sat_aug_document_checklist') }}
    where DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET is not null
