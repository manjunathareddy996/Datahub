{{ config(materialized='view') }}

-- FEED for SAT_COMMON_ADMIN_GEOGRAPHY (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_COMMON_ADMIN_GEOGRAPHY to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        LOCATION_HKEY__CUSTOMER_ANALYTICS_LOCATION as LOCATION_HKEY,
        COUNTRY_CODE as COUNTRY_CODE,
        DISTRICT_NAME as DISTRICT_NAME,
        STATE_CODE as STATE_CODE,
        STATE_NAME__SAT_COMMON_ADMIN_GEOGRAPHY as STATE_NAME,
        TALUKA_NAME as TALUKA_NAME,
        HASHDIFF_COMMON_ADMIN_GEOGRAPHY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where LOCATION_HKEY__CUSTOMER_ANALYTICS_LOCATION is not null
