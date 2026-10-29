{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_COMMON_ADDRESS: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        LOCATION_HKEY__PERMANENT_OVERSEAS as LOCATION_HKEY,
        FULL_ADDRESS_TEXT,
        HASHDIFF_COMMON_ADDRESS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_mbr_pp_sp_pv__sat_aug_common_address') }}
    where LOCATION_HKEY__PERMANENT_OVERSEAS is not null
union all
    select
        LOCATION_HKEY__PERMANENT_OVERSEAS as LOCATION_HKEY,
        FULL_ADDRESS_TEXT,
        HASHDIFF_COMMON_ADDRESS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_prp_pp_sp_pv__sat_aug_common_address') }}
    where LOCATION_HKEY__PERMANENT_OVERSEAS is not null
