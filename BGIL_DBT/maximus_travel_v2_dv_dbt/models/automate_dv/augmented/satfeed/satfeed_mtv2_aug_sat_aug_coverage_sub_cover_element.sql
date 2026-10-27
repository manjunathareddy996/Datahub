{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_COVERAGE_SUB_COVER_ELEMENT: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        SUB_COVER_CODE,
        SUB_COVER_APPLICABILITY,
        HASHDIFF_COVERAGE_SUB_COVER_ELEMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_cov_covp_msp_msd_prop_pv__sat_aug_coverage_sub_cover_element') }}
    where COVERAGE_HKEY is not null
