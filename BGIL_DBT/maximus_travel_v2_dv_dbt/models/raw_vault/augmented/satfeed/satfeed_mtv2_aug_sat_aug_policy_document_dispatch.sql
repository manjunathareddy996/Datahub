{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_DOCUMENT_DISPATCH: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        DISPATCH_SERIAL_NUMBER,
        COURIER_NAME,
        DELIVERY_MODE,
        DELIVERY_STATUS,
        DISPATCHED_DOCUMENT_TYPE,
        DISPATCH_DATE,
        DISPATCH_DESTINATION_TYPE,
        DISPATCH_PRIORITY,
        DISPATCH_REMARKS,
        PROOF_OF_DELIVERY_NUMBER,
        RECIPIENT_NAME,
        HASHDIFF_POLICY_DOCUMENT_DISPATCH as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_disp__sat_aug_policy_document_dispatch') }}
    where POLICY_HKEY is not null
