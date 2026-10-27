{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_QUOTE_TERMS: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        CANCELLATION_PREMIUM_BASIS,
        CHILD_POLICY_PLAN_CODE,
        CO_INSURANCE_INDICATOR,
        CUSTOMISED_PRODUCT_INDICATOR,
        EXCLUDED_COUNTRIES_DESCRIPTION,
        EXCLUDED_COUNTRIES_REMARKS,
        EXCLUDED_EVENTS_DESCRIPTION,
        EXCLUDED_EVENTS_REMARKS,
        JURISDICTION_COUNTRY_CODE,
        MANDATORY_QUESTIONNAIRE_INDICATOR,
        UNDERWRITING_RULES_BYPASSED_INDICATOR,
        HASHDIFF_QUOTE_TERMS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_polp_rl_pv__sat_aug_quote_terms') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        CANCELLATION_PREMIUM_BASIS,
        CHILD_POLICY_PLAN_CODE,
        CO_INSURANCE_INDICATOR,
        CUSTOMISED_PRODUCT_INDICATOR,
        EXCLUDED_COUNTRIES_DESCRIPTION,
        EXCLUDED_COUNTRIES_REMARKS,
        EXCLUDED_EVENTS_DESCRIPTION,
        EXCLUDED_EVENTS_REMARKS,
        JURISDICTION_COUNTRY_CODE,
        MANDATORY_QUESTIONNAIRE_INDICATOR,
        UNDERWRITING_RULES_BYPASSED_INDICATOR,
        HASHDIFF_QUOTE_TERMS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl__sat_aug_quote_terms') }}
    where QUOTE_HKEY is not null
