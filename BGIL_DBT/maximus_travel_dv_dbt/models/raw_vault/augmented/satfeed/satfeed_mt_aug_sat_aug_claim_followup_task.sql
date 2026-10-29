{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_FOLLOWUP_TASK: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        ASSIGNED_TO_REFERENCE,
        CREATED_BY_REFERENCE,
        CREATED_DATE,
        EVENT_EFFECTIVE_DATE,
        FOLLOWUP_DESCRIPTION,
        FOLLOWUP_EVENT_CODE,
        FOLLOWUP_STATUS,
        FOLLOWUP_TIMESTAMP,
        JOB_STATUS,
        KEYWORD,
        LAST_UPDATED_BY_REFERENCE,
        LAST_UPDATED_DATE,
        PRIORITY_INDICATOR,
        HASHDIFF_CLAIM_FOLLOWUP_TASK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_claim_event_followup__sat_aug_claim_followup_task') }}
    where CLAIM_HKEY is not null
