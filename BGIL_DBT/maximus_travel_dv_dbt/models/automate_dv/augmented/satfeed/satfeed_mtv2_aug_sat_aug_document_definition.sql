{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_DOCUMENT_DEFINITION: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET as DOCUMENT_HKEY,
        COURIER_NAME,
        DOCUMENT_DETAILS_TEXT,
        PROOF_OF_DELIVERY_NUMBER,
        RECORD_VALID_INDICATOR,
        SENDER_NAME,
        SPECIAL_ENCLOSURES_DETAILS,
        SPECIAL_ENCLOSURES_INDICATOR,
        HASHDIFF_DOCUMENT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clma_msp_msd_prop_pv__sat_aug_document_definition') }}
    where DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET is not null
union all
    select
        DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET as DOCUMENT_HKEY,
        COURIER_NAME,
        DOCUMENT_DETAILS_TEXT,
        PROOF_OF_DELIVERY_NUMBER,
        RECORD_VALID_INDICATOR,
        SENDER_NAME,
        SPECIAL_ENCLOSURES_DETAILS,
        SPECIAL_ENCLOSURES_INDICATOR,
        HASHDIFF_DOCUMENT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_document_definition') }}
    where DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET is not null
