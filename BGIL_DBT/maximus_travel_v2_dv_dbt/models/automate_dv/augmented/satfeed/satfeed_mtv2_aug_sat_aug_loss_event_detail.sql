{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_LOSS_EVENT_DETAIL: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        LOSS_EVENT_HKEY__V2 as LOSS_EVENT_HKEY,
        POLICE_REPORT_TIME,
        HASHDIFF_LOSS_EVENT_DETAIL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_loss_event_detail') }}
    where LOSS_EVENT_HKEY__V2 is not null
