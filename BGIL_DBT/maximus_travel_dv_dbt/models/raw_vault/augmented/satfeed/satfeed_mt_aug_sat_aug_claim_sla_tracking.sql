{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_SLA_TRACKING: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        CASE_MANAGEMENT_INDICATOR,
        CLAIM_ACTION_REASON_CODE,
        FURTHER_EXECUTION_REQUIRED_INDICATOR,
        LOSS_MANAGEMENT_CASE_STATUS,
        LOSS_MANAGEMENT_INTERIM_UPDATE,
        OUTSTANDING_REQUIREMENT_STATUS,
        PRIORITY_SERVICE_INDICATOR,
        REGISTRATION_TAT_BREACH_INDICATOR,
        RISK_PRIORITY_REVIEW_FEEDBACK,
        WORKFLOW_TRIGGER_REASON,
        WORK_BUCKET_DESCRIPTION,
        HASHDIFF_CLAIM_SLA_TRACKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmap_pv__sat_aug_claim_sla_tracking') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        CASE_MANAGEMENT_INDICATOR,
        CLAIM_ACTION_REASON_CODE,
        FURTHER_EXECUTION_REQUIRED_INDICATOR,
        LOSS_MANAGEMENT_CASE_STATUS,
        LOSS_MANAGEMENT_INTERIM_UPDATE,
        OUTSTANDING_REQUIREMENT_STATUS,
        PRIORITY_SERVICE_INDICATOR,
        REGISTRATION_TAT_BREACH_INDICATOR,
        RISK_PRIORITY_REVIEW_FEEDBACK,
        WORKFLOW_TRIGGER_REASON,
        WORK_BUCKET_DESCRIPTION,
        HASHDIFF_CLAIM_SLA_TRACKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__clm_clmd_clmrsk_rska_properties_pv__sat_aug_claim_sla_tracking') }}
    where CLAIM_HKEY is not null
