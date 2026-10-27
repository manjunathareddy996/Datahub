{{ config(materialized='view') }}

-- FEED for SAT_RISK_OBJECT_VALUATION (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_RISK_OBJECT_VALUATION to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        RISK_OBJECT_HKEY__INSURED_RISK_LINE as RISK_OBJECT_HKEY,
        INSURED_VALUE as INSURED_VALUE,
        HASHDIFF_RISK_OBJECT_VALUATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins') }}
    where RISK_OBJECT_HKEY__INSURED_RISK_LINE is not null
union all
    select
        RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        INSURED_VALUE as INSURED_VALUE,
        HASHDIFF_RISK_OBJECT_VALUATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        INSURED_VALUE as INSURED_VALUE,
        HASHDIFF_RISK_OBJECT_VALUATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        INSURED_VALUE as INSURED_VALUE,
        HASHDIFF_RISK_OBJECT_VALUATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }}
    where RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK is not null
