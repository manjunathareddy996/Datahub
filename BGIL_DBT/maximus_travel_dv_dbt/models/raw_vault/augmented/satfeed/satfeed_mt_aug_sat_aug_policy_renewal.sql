{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_RENEWAL: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        EXPIRING_POLICY_INSURER_NAME,
        RENEWAL_APPLICABLE_INDICATOR,
        RENEWAL_INDICATOR,
        RENEWAL_NOTICE_EXCEPTION_CLUSTER_NAME,
        RENEWAL_QUOTE_GENERATED_INDICATOR,
        REPLACED_POLICY_EXPIRY_DATE,
        REPLACED_POLICY_INCEPTION_DATE,
        REPLACED_POLICY_PRODUCT_CODE,
        HASHDIFF_POLICY_RENEWAL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol__sat_aug_policy_renewal') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        EXPIRING_POLICY_INSURER_NAME,
        RENEWAL_APPLICABLE_INDICATOR,
        RENEWAL_INDICATOR,
        RENEWAL_NOTICE_EXCEPTION_CLUSTER_NAME,
        RENEWAL_QUOTE_GENERATED_INDICATOR,
        REPLACED_POLICY_EXPIRY_DATE,
        REPLACED_POLICY_INCEPTION_DATE,
        REPLACED_POLICY_PRODUCT_CODE,
        HASHDIFF_POLICY_RENEWAL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_aug__uwr_pol_polp_sp_pv__sat_aug_policy_renewal') }}
    where POLICY_HKEY is not null
