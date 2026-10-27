{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_RISK_HEALTH_MEMBER_MEDICAL: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        CONDITION_CODE,
        MEMBER_REFERENCE,
        CONDITION_DESCRIPTION,
        CURRENT_MEDICATION_DETAIL,
        PRE_EXISTING_DISEASE_ONSET_MONTH,
        PRE_EXISTING_DISEASE_ONSET_YEAR,
        HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_rskp_msp_msd_prop_pv__sat_aug_risk_health_member_medical') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        CONDITION_CODE,
        MEMBER_REFERENCE,
        CONDITION_DESCRIPTION,
        CURRENT_MEDICATION_DETAIL,
        PRE_EXISTING_DISEASE_ONSET_MONTH,
        PRE_EXISTING_DISEASE_ONSET_YEAR,
        HASHDIFF_RISK_HEALTH_MEMBER_MEDICAL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl_msp_imsd_inp_pv__sat_aug_risk_health_member_medical') }}
    where RISK_OBJECT_HKEY is not null
