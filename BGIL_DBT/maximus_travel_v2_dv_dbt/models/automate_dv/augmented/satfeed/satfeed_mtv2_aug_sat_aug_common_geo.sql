{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_COMMON_GEO: unions 3 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        LOCATION_HKEY as LOCATION_HKEY,
        ALTITUDE,
        HASHDIFF_COMMON_GEO as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_mbr_pa_address_prop_pv__sat_aug_common_geo') }}
    where LOCATION_HKEY is not null
union all
    select
        LOCATION_HKEY as LOCATION_HKEY,
        ALTITUDE,
        HASHDIFF_COMMON_GEO as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_off_oa_address_prop_pv__sat_aug_common_geo') }}
    where LOCATION_HKEY is not null
union all
    select
        LOCATION_HKEY as LOCATION_HKEY,
        ALTITUDE,
        HASHDIFF_COMMON_GEO as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_prp_pa_address_prop_pv__sat_aug_common_geo') }}
    where LOCATION_HKEY is not null
