{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_RISK_OBJECT_CORE: unions 3 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        RISK_OBJECT_HKEY__INSURED_RISK_LINE as RISK_OBJECT_HKEY,
        RISK_ENTRY_DATE,
        RISK_LEVEL_EXCHANGE_RATE,
        RISK_LINE_SEQUENCE_NUMBER,
        HASHDIFF_RISK_OBJECT_CORE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins__sat_aug_risk_object_core') }}
    where RISK_OBJECT_HKEY__INSURED_RISK_LINE is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        RISK_ENTRY_DATE,
        RISK_LEVEL_EXCHANGE_RATE,
        RISK_LINE_SEQUENCE_NUMBER,
        HASHDIFF_RISK_OBJECT_CORE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_rskp_sp_pv__sat_aug_risk_object_core') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        RISK_ENTRY_DATE,
        RISK_LEVEL_EXCHANGE_RATE,
        RISK_LINE_SEQUENCE_NUMBER,
        HASHDIFF_RISK_OBJECT_CORE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl_rskp_rl_pv__sat_aug_risk_object_core') }}
    where RISK_OBJECT_HKEY is not null
