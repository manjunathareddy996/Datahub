{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_RISK_TRAVEL_COVER_TERMS: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        SUB_COVER_CODE,
        ACE_COVER_DURATION,
        ACE_SUM_INSURED,
        SUB_COVER_SUM_INSURED,
        HASHDIFF_RISK_TRAVEL_COVER_TERMS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_rskp_msp_msd_prop_pv__sat_aug_risk_travel_cover_terms') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        SUB_COVER_CODE,
        ACE_COVER_DURATION,
        ACE_SUM_INSURED,
        SUB_COVER_SUM_INSURED,
        HASHDIFF_RISK_TRAVEL_COVER_TERMS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_qpd_rskl_msp_imsd_inp_pv__sat_aug_risk_travel_cover_terms') }}
    where RISK_OBJECT_HKEY is not null
