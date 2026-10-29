{{ config(materialized='view') }}

-- FEED for SAT_RISK_PERSON_INSURED (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_RISK_PERSON_INSURED to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        INSURED_MEMBER_NAME as INSURED_MEMBER_NAME,
        MEMBER_TYPE as MEMBER_TYPE,
        PRE_EXISTING_DISEASE_DESCRIPTION as PRE_EXISTING_DISEASE_DESCRIPTION,
        PRE_EXISTING_DISEASE_INDICATOR as PRE_EXISTING_DISEASE_INDICATOR,
        SMOKER_INDICATOR as SMOKER_INDICATOR,
        HASHDIFF_RISK_PERSON_INSURED as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        INSURED_MEMBER_NAME as INSURED_MEMBER_NAME,
        MEMBER_TYPE as MEMBER_TYPE,
        PRE_EXISTING_DISEASE_DESCRIPTION as PRE_EXISTING_DISEASE_DESCRIPTION,
        PRE_EXISTING_DISEASE_INDICATOR as PRE_EXISTING_DISEASE_INDICATOR,
        SMOKER_INDICATOR as SMOKER_INDICATOR,
        HASHDIFF_RISK_PERSON_INSURED as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
    where RISK_OBJECT_HKEY is not null
