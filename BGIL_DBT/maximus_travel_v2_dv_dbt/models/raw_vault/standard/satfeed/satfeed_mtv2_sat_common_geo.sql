{{ config(materialized='view') }}

-- FEED for SAT_COMMON_GEO (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 3 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_COMMON_GEO to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        LOCATION_HKEY as LOCATION_HKEY,
        LATITUDE as LATITUDE,
        LONGITUDE as LONGITUDE,
        ALTITUDE as ALTITUDE,
        HASHDIFF_COMMON_GEO as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pa_address_prop_pv') }}
    where LOCATION_HKEY is not null
union all
    select
        LOCATION_HKEY as LOCATION_HKEY,
        LATITUDE as LATITUDE,
        LONGITUDE as LONGITUDE,
        ALTITUDE as ALTITUDE,
        HASHDIFF_COMMON_GEO as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_off_oa_address_prop_pv') }}
    where LOCATION_HKEY is not null
union all
    select
        LOCATION_HKEY as LOCATION_HKEY,
        LATITUDE as LATITUDE,
        LONGITUDE as LONGITUDE,
        ALTITUDE as ALTITUDE,
        HASHDIFF_COMMON_GEO as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pa_address_prop_pv') }}
    where LOCATION_HKEY is not null
