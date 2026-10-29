{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_STATUS_HISTORY: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        CLAIM_STATUS_AT_EVENT,
        CLAIM_SUB_STATUS_AT_EVENT,
        DELAY_REASON,
        ENTRY_CREATED_DATE,
        EVENT_CODE,
        EVENT_DATE,
        EVENT_DESCRIPTION,
        EVENT_DETAILS,
        EVENT_REFERENCE_NUMBER,
        EVENT_REMARKS,
        HISTORY_ENTRY_TYPE,
        PPI_INDICATOR,
        RECORDED_BY_USER_REFERENCE,
        REQUIREMENT_STATUS,
        SCRUTINY_STATUS,
        SURVEY_REPORT_STATUS,
        HASHDIFF_CLAIM_STATUS_HISTORY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_claim_history__sat_aug_claim_status_history') }}
    where CLAIM_HKEY is not null
