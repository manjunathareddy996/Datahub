{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_ENDORSEMENT: unions 2 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        ENDORSEMENT_NUMBER,
        ENDORSEMENT_APPROVAL_DATE,
        ENDORSEMENT_INVOICE_REFERENCE,
        ENDORSEMENT_REMARKS,
        ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE,
        REVISED_SUM_INSURED_AMOUNT,
        HASHDIFF_POLICY_ENDORSEMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_endt__sat_aug_policy_endorsement') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        ENDORSEMENT_NUMBER,
        ENDORSEMENT_APPROVAL_DATE,
        ENDORSEMENT_INVOICE_REFERENCE,
        ENDORSEMENT_REMARKS,
        ENDORSEMENT_UNIQUE_IDENTIFICATION_CODE,
        REVISED_SUM_INSURED_AMOUNT,
        HASHDIFF_POLICY_ENDORSEMENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_polp_sp_pv__sat_aug_policy_endorsement') }}
    where POLICY_HKEY is not null
