{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_DOCUMENT_DISPATCH: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        DOCUMENT_HKEY as DOCUMENT_HKEY,
        COURIER_NAME,
        INWARD_DATE,
        PROOF_OF_DELIVERY_NUMBER,
        SENDER_NAME,
        SPECIAL_ENCLOSURES_DESCRIPTION,
        SPECIAL_ENCLOSURES_INDICATOR,
        HASHDIFF_DOCUMENT_DISPATCH as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmcov_msd_prop_pv__sat_aug_document_dispatch') }}
    where DOCUMENT_HKEY is not null
