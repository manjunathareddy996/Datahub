{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_INSURED_DECLARATION: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        AGE_BAND,
        CURRENT_MEDICATION_DETAIL,
        DATE_OF_BIRTH,
        PRE_EXISTING_DISEASE_CODE,
        PRE_EXISTING_DISEASE_DESCRIPTION,
        HASHDIFF_POLICY_INSURED_DECLARATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_polp_msp_msd_prop_pv__sat_aug_policy_insured_declaration') }}
    where POLICY_HKEY is not null
