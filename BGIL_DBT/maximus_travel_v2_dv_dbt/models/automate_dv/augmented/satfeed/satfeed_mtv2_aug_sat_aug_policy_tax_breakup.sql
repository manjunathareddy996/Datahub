{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_TAX_BREAKUP: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        GST_BIFURCATION,
        GST_TDS_AMOUNT,
        GST_TYPE,
        STAMP_DUTY_RECEIPT_NUMBER,
        TOTAL_TAX_AMOUNT,
        HASHDIFF_POLICY_TAX_BREAKUP as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_polp_sp_pv__sat_aug_policy_tax_breakup') }}
    where POLICY_HKEY is not null
