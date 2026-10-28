{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_RISK_PERSON_INSURED: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        ALCOHOL_USE_INDICATOR,
        EMPLOYEE_NUMBER,
        GOOD_HEALTH_DECLARATION_INDICATOR,
        INSURED_SAME_AS_POLICYHOLDER_INDICATOR,
        MEDICAL_CHECK_REQUIRED_INDICATOR,
        NOMINEE_DETAILS,
        OTHER_INSURANCE_HELD_DETAIL,
        PREVIOUS_CLAIM_DECLARATION_DETAIL,
        RECREATIONAL_DRUG_USE_INDICATOR,
        RELATIONSHIP_TO_PRIMARY_INSURED,
        HASHDIFF_RISK_PERSON_INSURED as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_rskp_sp_pv__sat_aug_risk_person_insured') }}
    where RISK_OBJECT_HKEY__INSURED_TRAVELLER_RISK is not null
union all
    select
        RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK as RISK_OBJECT_HKEY,
        ALCOHOL_USE_INDICATOR,
        EMPLOYEE_NUMBER,
        GOOD_HEALTH_DECLARATION_INDICATOR,
        INSURED_SAME_AS_POLICYHOLDER_INDICATOR,
        MEDICAL_CHECK_REQUIRED_INDICATOR,
        NOMINEE_DETAILS,
        OTHER_INSURANCE_HELD_DETAIL,
        PREVIOUS_CLAIM_DECLARATION_DETAIL,
        RECREATIONAL_DRUG_USE_INDICATOR,
        RELATIONSHIP_TO_PRIMARY_INSURED,
        HASHDIFF_RISK_PERSON_INSURED as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl_rskp_rl_pv__sat_aug_risk_person_insured') }}
    where RISK_OBJECT_HKEY__QUOTED_TRAVELLER_RISK is not null
