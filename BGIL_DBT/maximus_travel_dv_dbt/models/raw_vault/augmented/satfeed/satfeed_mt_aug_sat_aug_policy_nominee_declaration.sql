{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_NOMINEE_DECLARATION: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        APPOINTEE_NAME,
        NOMINATION_PERCENTAGE,
        NOMINEE_NAME,
        RELATIONSHIP_TO_INSURED,
        HASHDIFF_POLICY_NOMINEE_DECLARATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_polp_msp_msd_prop_pv__sat_aug_policy_nominee_declaration') }}
    where POLICY_HKEY is not null
