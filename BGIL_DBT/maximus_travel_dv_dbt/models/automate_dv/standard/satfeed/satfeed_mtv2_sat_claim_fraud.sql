{{ config(materialized='view') }}

-- FEED for SAT_CLAIM_FRAUD (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 6 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CLAIM_FRAUD to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        FRAUD_SCORE as FRAUD_SCORE,
        FRAUD_TRIGGER_REASON as FRAUD_TRIGGER_REASON,
        FRAUD_TYPE as FRAUD_TYPE,
        INVESTIGATION_REFERENCE as INVESTIGATION_REFERENCE,
        INVESTIGATION_REFERRED_INDICATOR as INVESTIGATION_REFERRED_INDICATOR,
        INVESTIGATION_STATUS as INVESTIGATION_STATUS,
        HASHDIFF_CLAIM_FRAUD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clma_msp_msd_prop_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        FRAUD_SCORE as FRAUD_SCORE,
        FRAUD_TRIGGER_REASON as FRAUD_TRIGGER_REASON,
        FRAUD_TYPE as FRAUD_TYPE,
        INVESTIGATION_REFERENCE as INVESTIGATION_REFERENCE,
        INVESTIGATION_REFERRED_INDICATOR as INVESTIGATION_REFERRED_INDICATOR,
        INVESTIGATION_STATUS as INVESTIGATION_STATUS,
        HASHDIFF_CLAIM_FRAUD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        FRAUD_SCORE as FRAUD_SCORE,
        FRAUD_TRIGGER_REASON as FRAUD_TRIGGER_REASON,
        FRAUD_TYPE as FRAUD_TYPE,
        INVESTIGATION_REFERENCE as INVESTIGATION_REFERENCE,
        INVESTIGATION_REFERRED_INDICATOR as INVESTIGATION_REFERRED_INDICATOR,
        INVESTIGATION_STATUS as INVESTIGATION_STATUS,
        HASHDIFF_CLAIM_FRAUD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        FRAUD_SCORE as FRAUD_SCORE,
        FRAUD_TRIGGER_REASON as FRAUD_TRIGGER_REASON,
        FRAUD_TYPE as FRAUD_TYPE,
        INVESTIGATION_REFERENCE as INVESTIGATION_REFERENCE,
        INVESTIGATION_REFERRED_INDICATOR as INVESTIGATION_REFERRED_INDICATOR,
        INVESTIGATION_STATUS as INVESTIGATION_STATUS,
        HASHDIFF_CLAIM_FRAUD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_properties_pv') }}
    where CLAIM_HKEY is not null
