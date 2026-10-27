{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_CLAIM_HEADER: unions 3 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        CLAIM_HKEY as CLAIM_HKEY,
        ADD_ON_COVERS_CLAIMED,
        CERTIFICATE_OF_INSURANCE_STATUS,
        CLAIM_CLOSE_REASON,
        CLAIM_LOCATION_CODE,
        CLAIM_STATE,
        CLONE_TYPE,
        HEAD_OFFICE_ORG_UNIT_CODE,
        LOSS_CAUSE_DESCRIPTION,
        PRIMARY_CAUSE_OF_LOSS_CODE,
        PRIMARY_CAUSE_OF_LOSS_DESCRIPTION,
        REGISTRATION_ORG_UNIT_CODE,
        REGISTRATION_TIME,
        REOPENING_TYPE,
        ROADSIDE_ASSISTANCE_REQUIRED_INDICATOR,
        SECONDARY_CAUSE_OF_LOSS_CODE,
        SECONDARY_CAUSE_OF_LOSS_DESCRIPTION,
        HASHDIFF_CLAIM_HEADER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd__sat_aug_claim_header') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        ADD_ON_COVERS_CLAIMED,
        CERTIFICATE_OF_INSURANCE_STATUS,
        CLAIM_CLOSE_REASON,
        CLAIM_LOCATION_CODE,
        CLAIM_STATE,
        CLONE_TYPE,
        HEAD_OFFICE_ORG_UNIT_CODE,
        LOSS_CAUSE_DESCRIPTION,
        PRIMARY_CAUSE_OF_LOSS_CODE,
        PRIMARY_CAUSE_OF_LOSS_DESCRIPTION,
        REGISTRATION_ORG_UNIT_CODE,
        REGISTRATION_TIME,
        REOPENING_TYPE,
        ROADSIDE_ASSISTANCE_REQUIRED_INDICATOR,
        SECONDARY_CAUSE_OF_LOSS_CODE,
        SECONDARY_CAUSE_OF_LOSS_DESCRIPTION,
        HASHDIFF_CLAIM_HEADER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmap_pv__sat_aug_claim_header') }}
    where CLAIM_HKEY is not null
union all
    select
        CLAIM_HKEY as CLAIM_HKEY,
        ADD_ON_COVERS_CLAIMED,
        CERTIFICATE_OF_INSURANCE_STATUS,
        CLAIM_CLOSE_REASON,
        CLAIM_LOCATION_CODE,
        CLAIM_STATE,
        CLONE_TYPE,
        HEAD_OFFICE_ORG_UNIT_CODE,
        LOSS_CAUSE_DESCRIPTION,
        PRIMARY_CAUSE_OF_LOSS_CODE,
        PRIMARY_CAUSE_OF_LOSS_DESCRIPTION,
        REGISTRATION_ORG_UNIT_CODE,
        REGISTRATION_TIME,
        REOPENING_TYPE,
        ROADSIDE_ASSISTANCE_REQUIRED_INDICATOR,
        SECONDARY_CAUSE_OF_LOSS_CODE,
        SECONDARY_CAUSE_OF_LOSS_DESCRIPTION,
        HASHDIFF_CLAIM_HEADER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__clm_clmd_clmrsk_rska_msp_msd_prop_pv__sat_aug_claim_header') }}
    where CLAIM_HKEY is not null
