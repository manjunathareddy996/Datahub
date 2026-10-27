{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_RISK_TRAVEL_SPONSOR: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        SPONSOR_CONTACT_NUMBER,
        SPONSOR_NAME,
        HASHDIFF_RISK_TRAVEL_SPONSOR as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_rskp_sp_pv__sat_aug_risk_travel_sponsor') }}
    where RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK is not null
union all
    select
        RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        SPONSOR_CONTACT_NUMBER,
        SPONSOR_NAME,
        HASHDIFF_RISK_TRAVEL_SPONSOR as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl_rskp_rl_pv__sat_aug_risk_travel_sponsor') }}
    where RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK is not null
