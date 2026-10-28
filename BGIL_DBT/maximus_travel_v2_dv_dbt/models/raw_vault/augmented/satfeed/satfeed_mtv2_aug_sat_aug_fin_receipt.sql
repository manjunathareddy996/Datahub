{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_FIN_RECEIPT: unions 3 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        FINANCIAL_TRANSACTION_HKEY as FINANCIAL_TRANSACTION_HKEY,
        COLLECTION_DATE,
        PORTAL_PAYMENT_MODE_CODE,
        HASHDIFF_FIN_RECEIPT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_policy_payment_information__sat_aug_fin_receipt') }}
    where FINANCIAL_TRANSACTION_HKEY is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        COLLECTION_DATE,
        PORTAL_PAYMENT_MODE_CODE,
        HASHDIFF_FIN_RECEIPT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_polp_sp_pv__sat_aug_fin_receipt') }}
    where FINANCIAL_TRANSACTION_HKEY__POLICY_PREMIUM is not null
union all
    select
        FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM as FINANCIAL_TRANSACTION_HKEY,
        COLLECTION_DATE,
        PORTAL_PAYMENT_MODE_CODE,
        HASHDIFF_FIN_RECEIPT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_polp_rl_pv__sat_aug_fin_receipt') }}
    where FINANCIAL_TRANSACTION_HKEY__QUOTE_PREMIUM is not null
