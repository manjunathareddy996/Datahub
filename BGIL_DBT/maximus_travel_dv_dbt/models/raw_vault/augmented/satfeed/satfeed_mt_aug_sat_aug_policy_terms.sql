{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_TERMS: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        CUSTOMISED_PRODUCT_INDICATOR,
        EXCLUDED_COUNTRIES_DESCRIPTION,
        EXCLUDED_COUNTRIES_REMARKS,
        EXCLUDED_EVENTS_DESCRIPTION,
        EXCLUDED_EVENTS_REMARKS,
        MANDATORY_QUESTIONNAIRE_INDICATOR,
        UNDERWRITING_RULES_BYPASSED_INDICATOR,
        HASHDIFF_POLICY_TERMS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_polp_sp_pv__sat_aug_policy_terms') }}
    where POLICY_HKEY is not null
