{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_APPROVAL_ACTION: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        ACTION_CLOSURE_DATE,
        ACTION_REMARKS,
        APPROVAL_DECISION,
        APPROVAL_STATUS,
        APPROVER_REFERENCE,
        APPROVER_REMARKS,
        LAST_UPDATED_BY_REFERENCE,
        REQUESTOR_REFERENCE,
        REQUESTOR_REMARKS,
        HASHDIFF_CLAIM_APPROVAL_ACTION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clma_msp_msd_prop_pv__sat_aug_claim_approval_action') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        ACTION_CLOSURE_DATE,
        ACTION_REMARKS,
        APPROVAL_DECISION,
        APPROVAL_STATUS,
        APPROVER_REFERENCE,
        APPROVER_REMARKS,
        LAST_UPDATED_BY_REFERENCE,
        REQUESTOR_REFERENCE,
        REQUESTOR_REMARKS,
        HASHDIFF_CLAIM_APPROVAL_ACTION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_aug_claim_approval_action') }}
    where CLAIM_HKEY is not null
