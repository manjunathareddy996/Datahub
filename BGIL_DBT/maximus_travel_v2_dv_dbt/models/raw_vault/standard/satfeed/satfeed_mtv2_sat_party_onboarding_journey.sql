{{ config(materialized='view') }}

-- FEED for SAT_PARTY_ONBOARDING_JOURNEY (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 4 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PARTY_ONBOARDING_JOURNEY to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        EXAMINATION_REFERENCE as EXAMINATION_REFERENCE,
        ONBOARDING_START_DATE as ONBOARDING_START_DATE,
        PREVIOUS_EMPLOYER_NAME as PREVIOUS_EMPLOYER_NAME,
        PRIOR_WORK_EXPERIENCE_YEARS as PRIOR_WORK_EXPERIENCE_YEARS,
        HASHDIFF_PARTY_ONBOARDING_JOURNEY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_HKEY__PROPOSER is not null
