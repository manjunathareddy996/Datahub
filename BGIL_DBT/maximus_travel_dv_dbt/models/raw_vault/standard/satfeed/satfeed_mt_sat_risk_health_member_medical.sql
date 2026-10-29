{{ config(materialized='view') }}

-- FEED for SAT_RISK_HEALTH_MEMBER_MEDICAL (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 2 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        CONDITION_CODE as CONDITION_CODE,
        MEMBER_REFERENCE as MEMBER_REFERENCE,
        CONDITION_NAME as CONDITION_NAME,
        CONDITION_DESCRIPTION as CONDITION_DESCRIPTION,
        CURRENT_MEDICATION_DETAIL as CURRENT_MEDICATION_DETAIL,
        PRE_EXISTING_DISEASE_ONSET_MONTH as PRE_EXISTING_DISEASE_ONSET_MONTH,
        PRE_EXISTING_DISEASE_ONSET_YEAR as PRE_EXISTING_DISEASE_ONSET_YEAR,
        HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        CONDITION_CODE as CONDITION_CODE,
        MEMBER_REFERENCE as MEMBER_REFERENCE,
        CONDITION_NAME as CONDITION_NAME,
        CONDITION_DESCRIPTION as CONDITION_DESCRIPTION,
        CURRENT_MEDICATION_DETAIL as CURRENT_MEDICATION_DETAIL,
        PRE_EXISTING_DISEASE_ONSET_MONTH as PRE_EXISTING_DISEASE_ONSET_MONTH,
        PRE_EXISTING_DISEASE_ONSET_YEAR as PRE_EXISTING_DISEASE_ONSET_YEAR,
        HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where RISK_OBJECT_HKEY is not null
