{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        ACTIVE_SEQUENCE_NUMBER,
        BENEFIT_AMOUNT,
        DELAY_THRESHOLD_EXCEEDED,
        DELAY_THRESHOLD_EXCEEDED_ACE_VARIANT,
        LIMIT_SUM_INSURED_AMOUNT,
        LOADING_ACE_VARIANT,
        MAIN_SUB_COVER_LOADING_ACE_VARIANT,
        MAIN_SUB_COVER_RATE_PER_TRIP_PER_MILLE,
        MAIN_SUB_COVER_SUM_INSURED_ACE_VARIANT,
        OFFICE_PREMIUM_RATE_PER_MILLE_PER_ANNUM,
        OFFICE_PREMIUM_RATE_PER_MILLE_PER_TRIP,
        RATE_PER_TRIP_PER_MILLE,
        RATING_SLAB_BAND,
        SUB_LIMIT_DEDUCTIBLE_AMOUNT,
        SUB_LIMIT_PERIOD,
        SUM_INSURED_ACE_VARIANT,
        TRIP_TYPE_FOR_INCONVENIENCE_COVER,
        TRIP_TYPE_FOR_TRIP_CALCULATION,
        HASHDIFF_COVERAGE_SUBLIMIT_SCHEDULE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_ins_cov_covp_msp_msd_prop_pv__sat_aug_coverage_sublimit_schedule') }}
    where COVERAGE_HKEY is not null
