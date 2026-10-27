{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_PARTY_PORTFOLIO_SUMMARY: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_HKEY__CLAIMANT_CUSTOMER as PARTY_HKEY,
        CROSS_SELL_POLICIES_PURCHASED,
        CUSTOMER_ACTIVE_YEARS,
        LATEST_POLICY_ISSUANCE_LOCATION_NAME,
        LATEST_POLICY_LINE_OF_BUSINESS,
        LATEST_POLICY_PRODUCT_NAME,
        LATEST_POLICY_SUB_CHANNEL,
        MULTI_CHANNEL_PURCHASE_INDICATOR,
        HASHDIFF_PARTY_PORTFOLIO_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_party_portfolio_summary') }}
    where PARTY_HKEY__CLAIMANT_CUSTOMER is not null
