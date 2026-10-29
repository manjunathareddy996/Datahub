{{ config(materialized='view') }}

-- FEED for SAT_LNK_ROLE_CUSTOMER (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 3 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_LNK_ROLE_CUSTOMER to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_ROLE_HKEY__POLICYHOLDER as PARTY_ROLE_HKEY,
        CONSENT_FOR_DATA_SHARING_INDICATOR as CONSENT_FOR_DATA_SHARING_INDICATOR,
        PREFERRED_CUSTOMER_INDICATOR as PREFERRED_CUSTOMER_INDICATOR,
        VIP_INDICATOR as VIP_INDICATOR,
        HASHDIFF_LNK_ROLE_CUSTOMER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where PARTY_ROLE_HKEY__POLICYHOLDER is not null
union all
    select
        PARTY_ROLE_HKEY__PROPOSER as PARTY_ROLE_HKEY,
        CONSENT_FOR_DATA_SHARING_INDICATOR as CONSENT_FOR_DATA_SHARING_INDICATOR,
        PREFERRED_CUSTOMER_INDICATOR as PREFERRED_CUSTOMER_INDICATOR,
        VIP_INDICATOR as VIP_INDICATOR,
        HASHDIFF_LNK_ROLE_CUSTOMER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_ROLE_HKEY__PROPOSER is not null
union all
    select
        PARTY_ROLE_HKEY__POLICYHOLDER as PARTY_ROLE_HKEY,
        CONSENT_FOR_DATA_SHARING_INDICATOR as CONSENT_FOR_DATA_SHARING_INDICATOR,
        PREFERRED_CUSTOMER_INDICATOR as PREFERRED_CUSTOMER_INDICATOR,
        VIP_INDICATOR as VIP_INDICATOR,
        HASHDIFF_LNK_ROLE_CUSTOMER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where PARTY_ROLE_HKEY__POLICYHOLDER is not null
