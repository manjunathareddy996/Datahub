{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_PRODUCT_RATING_STRUCTURE: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        DEPOSIT_PREMIUM_BASIS,
        HASHDIFF_PRODUCT_RATING_STRUCTURE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_rskp_sp_pv__sat_aug_product_rating_structure') }}
    where PRODUCT_HKEY is not null
union all
    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        DEPOSIT_PREMIUM_BASIS,
        HASHDIFF_PRODUCT_RATING_STRUCTURE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_qpd_rskl_rskp_rl_pv__sat_aug_product_rating_structure') }}
    where PRODUCT_HKEY is not null
