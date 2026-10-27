{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_ASSESSMENT_HEADER: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        ASSESSMENT_HKEY__TELE_VERIFICATION as ASSESSMENT_HKEY,
        ASSESSMENT_END_TIME,
        ASSESSMENT_START_TIME,
        HASHDIFF_ASSESSMENT_HEADER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_tele__sat_aug_assessment_header') }}
    where ASSESSMENT_HKEY__TELE_VERIFICATION is not null
