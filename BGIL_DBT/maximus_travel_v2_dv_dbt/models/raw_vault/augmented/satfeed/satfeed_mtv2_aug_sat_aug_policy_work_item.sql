{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_WORK_ITEM: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        COMPLETED_DATE,
        RAISED_BY_REFERENCE,
        RAISED_DATE,
        TASK_REMARKS,
        TASK_STATUS,
        TASK_TYPE,
        HASHDIFF_POLICY_WORK_ITEM as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_wrk__sat_aug_policy_work_item') }}
    where POLICY_HKEY is not null
