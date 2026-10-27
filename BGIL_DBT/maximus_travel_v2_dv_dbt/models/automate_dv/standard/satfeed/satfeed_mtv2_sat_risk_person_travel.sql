{{ config(materialized='view') }}

-- FEED for SAT_RISK_PERSON_TRAVEL (target track): unions 7 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 6 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_RISK_PERSON_TRAVEL to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        DESTINATION_COUNTRY as DESTINATION_COUNTRY,
        GEOGRAPHICAL_ZONE as GEOGRAPHICAL_ZONE,
        TRIP_DURATION as TRIP_DURATION,
        TRIP_END_DATE as TRIP_END_DATE,
        TRIP_START_DATE as TRIP_START_DATE,
        TRIP_TYPE as TRIP_TYPE,
        HASHDIFF_RISK_PERSON_TRAVEL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov_covp_sp_pv') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        DESTINATION_COUNTRY as DESTINATION_COUNTRY,
        GEOGRAPHICAL_ZONE as GEOGRAPHICAL_ZONE,
        TRIP_DURATION as TRIP_DURATION,
        TRIP_END_DATE as TRIP_END_DATE,
        TRIP_START_DATE as TRIP_START_DATE,
        TRIP_TYPE as TRIP_TYPE,
        HASHDIFF_RISK_PERSON_TRAVEL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        DESTINATION_COUNTRY as DESTINATION_COUNTRY,
        GEOGRAPHICAL_ZONE as GEOGRAPHICAL_ZONE,
        TRIP_DURATION as TRIP_DURATION,
        TRIP_END_DATE as TRIP_END_DATE,
        TRIP_START_DATE as TRIP_START_DATE,
        TRIP_TYPE as TRIP_TYPE,
        HASHDIFF_RISK_PERSON_TRAVEL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        DESTINATION_COUNTRY as DESTINATION_COUNTRY,
        GEOGRAPHICAL_ZONE as GEOGRAPHICAL_ZONE,
        TRIP_DURATION as TRIP_DURATION,
        TRIP_END_DATE as TRIP_END_DATE,
        TRIP_START_DATE as TRIP_START_DATE,
        TRIP_TYPE as TRIP_TYPE,
        HASHDIFF_RISK_PERSON_TRAVEL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        DESTINATION_COUNTRY as DESTINATION_COUNTRY,
        GEOGRAPHICAL_ZONE as GEOGRAPHICAL_ZONE,
        TRIP_DURATION as TRIP_DURATION,
        TRIP_END_DATE as TRIP_END_DATE,
        TRIP_START_DATE as TRIP_START_DATE,
        TRIP_TYPE as TRIP_TYPE,
        HASHDIFF_RISK_PERSON_TRAVEL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        DESTINATION_COUNTRY as DESTINATION_COUNTRY,
        GEOGRAPHICAL_ZONE as GEOGRAPHICAL_ZONE,
        TRIP_DURATION as TRIP_DURATION,
        TRIP_END_DATE as TRIP_END_DATE,
        TRIP_START_DATE as TRIP_START_DATE,
        TRIP_TYPE as TRIP_TYPE,
        HASHDIFF_RISK_PERSON_TRAVEL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        DESTINATION_COUNTRY as DESTINATION_COUNTRY,
        GEOGRAPHICAL_ZONE as GEOGRAPHICAL_ZONE,
        TRIP_DURATION as TRIP_DURATION,
        TRIP_END_DATE as TRIP_END_DATE,
        TRIP_START_DATE as TRIP_START_DATE,
        TRIP_TYPE as TRIP_TYPE,
        HASHDIFF_RISK_PERSON_TRAVEL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }}
    where RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK is not null
