{{ config(materialized='view') }}

-- FEED for SAT_PARTY_HEALTH_PROFILE (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 6 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PARTY_HEALTH_PROFILE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        CURRENT_MEDICATION_DETAIL as CURRENT_MEDICATION_DETAIL,
        DISABILITY_INDICATOR as DISABILITY_INDICATOR,
        DISABILITY_PERCENTAGE as DISABILITY_PERCENTAGE,
        HEIGHT as HEIGHT,
        PRE_EXISTING_DISEASE_DESCRIPTION as PRE_EXISTING_DISEASE_DESCRIPTION,
        WEIGHT as WEIGHT,
        HASHDIFF_PARTY_HEALTH_PROFILE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        CURRENT_MEDICATION_DETAIL as CURRENT_MEDICATION_DETAIL,
        DISABILITY_INDICATOR as DISABILITY_INDICATOR,
        DISABILITY_PERCENTAGE as DISABILITY_PERCENTAGE,
        HEIGHT as HEIGHT,
        PRE_EXISTING_DISEASE_DESCRIPTION as PRE_EXISTING_DISEASE_DESCRIPTION,
        WEIGHT as WEIGHT,
        HASHDIFF_PARTY_HEALTH_PROFILE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_HKEY__PROPOSER is not null
