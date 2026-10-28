{{ config(materialized='view') }}

-- FEED for SAT_CLAIM_TRAVEL_DETAIL (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 6 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CLAIM_TRAVEL_DETAIL to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        CLAIM_SUB_TYPE as CLAIM_SUB_TYPE,
        COUNTRY_OF_INCIDENT as COUNTRY_OF_INCIDENT,
        CURRENCY_OF_LOSS as CURRENCY_OF_LOSS,
        INCIDENT_DATE as INCIDENT_DATE,
        LOSS_AMOUNT_FOREIGN as LOSS_AMOUNT_FOREIGN,
        LOSS_AMOUNT_INR as LOSS_AMOUNT_INR,
        HASHDIFF_CLAIM_TRAVEL_DETAIL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        CLAIM_SUB_TYPE as CLAIM_SUB_TYPE,
        COUNTRY_OF_INCIDENT as COUNTRY_OF_INCIDENT,
        CURRENCY_OF_LOSS as CURRENCY_OF_LOSS,
        INCIDENT_DATE as INCIDENT_DATE,
        LOSS_AMOUNT_FOREIGN as LOSS_AMOUNT_FOREIGN,
        LOSS_AMOUNT_INR as LOSS_AMOUNT_INR,
        HASHDIFF_CLAIM_TRAVEL_DETAIL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_msp_msd_prop_pv') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        CLAIM_SUB_TYPE as CLAIM_SUB_TYPE,
        COUNTRY_OF_INCIDENT as COUNTRY_OF_INCIDENT,
        CURRENCY_OF_LOSS as CURRENCY_OF_LOSS,
        INCIDENT_DATE as INCIDENT_DATE,
        LOSS_AMOUNT_FOREIGN as LOSS_AMOUNT_FOREIGN,
        LOSS_AMOUNT_INR as LOSS_AMOUNT_INR,
        HASHDIFF_CLAIM_TRAVEL_DETAIL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk_rska_properties_pv') }}
    where CLAIM_HKEY is not null
