{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_RISK_OBJECT_VALUATION: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        INSURED_VALUE_IN_SUM_INSURED_CURRENCY,
        INSURED_VALUE_IN_TRANSACTION_CURRENCY,
        HASHDIFF_RISK_OBJECT_VALUATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_rskp_sp_pv__sat_aug_risk_object_valuation') }}
    where RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK is not null
union all
    select
        RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        INSURED_VALUE_IN_SUM_INSURED_CURRENCY,
        INSURED_VALUE_IN_TRANSACTION_CURRENCY,
        HASHDIFF_RISK_OBJECT_VALUATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl_rskp_rl_pv__sat_aug_risk_object_valuation') }}
    where RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK is not null
