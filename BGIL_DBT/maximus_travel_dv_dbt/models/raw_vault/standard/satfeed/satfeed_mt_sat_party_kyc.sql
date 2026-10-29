{{ config(materialized='view') }}

-- FEED for SAT_PARTY_KYC (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 8 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PARTY_KYC to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        CKYC_REGISTRATION_STATUS as CKYC_REGISTRATION_STATUS,
        KYC_COMPLETION_DATE as KYC_COMPLETION_DATE,
        KYC_STATUS as KYC_STATUS,
        CKYC_DETAILS_NARRATIVE as CKYC_DETAILS_NARRATIVE,
        CKYC_NUMBER_HELD_DECLARED_INDICATOR as CKYC_NUMBER_HELD_DECLARED_INDICATOR,
        KYC_DETAILS_DESCRIPTION as KYC_DETAILS_DESCRIPTION,
        KYC_DETAIL_DESCRIPTION as KYC_DETAIL_DESCRIPTION,
        KYC_RELATED_DETAILS_DESCRIPTION as KYC_RELATED_DETAILS_DESCRIPTION,
        HASHDIFF_PARTY_KYC as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        CKYC_REGISTRATION_STATUS as CKYC_REGISTRATION_STATUS,
        KYC_COMPLETION_DATE as KYC_COMPLETION_DATE,
        KYC_STATUS as KYC_STATUS,
        CKYC_DETAILS_NARRATIVE as CKYC_DETAILS_NARRATIVE,
        CKYC_NUMBER_HELD_DECLARED_INDICATOR as CKYC_NUMBER_HELD_DECLARED_INDICATOR,
        KYC_DETAILS_DESCRIPTION as KYC_DETAILS_DESCRIPTION,
        KYC_DETAIL_DESCRIPTION as KYC_DETAIL_DESCRIPTION,
        KYC_RELATED_DETAILS_DESCRIPTION as KYC_RELATED_DETAILS_DESCRIPTION,
        HASHDIFF_PARTY_KYC as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_HKEY__PROPOSER is not null
