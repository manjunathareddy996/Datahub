{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_PARTY_BANKING: unions 4 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        APPROVED_OR_REJECTED_BY,
        APPROVED_OR_REJECTED_DATE,
        BANK_DETAIL_REMARKS,
        BANK_VERIFIED_ACCOUNT_HOLDER_NAME,
        NEFT_VERIFICATION_STATUS,
        PENNY_DROP_NAME_MATCH_SCORE,
        PENNY_DROP_WAIVED_INDICATOR,
        REFUND_TO_BANK_GUARANTEE_HOLDER_ACCOUNT_REFERENCE,
        HASHDIFF_PARTY_BANKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_mbr_pp_msp_msd_prop_pv__sat_aug_party_banking') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        APPROVED_OR_REJECTED_BY,
        APPROVED_OR_REJECTED_DATE,
        BANK_DETAIL_REMARKS,
        BANK_VERIFIED_ACCOUNT_HOLDER_NAME,
        NEFT_VERIFICATION_STATUS,
        PENNY_DROP_NAME_MATCH_SCORE,
        PENNY_DROP_WAIVED_INDICATOR,
        REFUND_TO_BANK_GUARANTEE_HOLDER_ACCOUNT_REFERENCE,
        HASHDIFF_PARTY_BANKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_ins_mbr_pp_sp_pv__sat_aug_party_banking') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        APPROVED_OR_REJECTED_BY,
        APPROVED_OR_REJECTED_DATE,
        BANK_DETAIL_REMARKS,
        BANK_VERIFIED_ACCOUNT_HOLDER_NAME,
        NEFT_VERIFICATION_STATUS,
        PENNY_DROP_NAME_MATCH_SCORE,
        PENNY_DROP_WAIVED_INDICATOR,
        REFUND_TO_BANK_GUARANTEE_HOLDER_ACCOUNT_REFERENCE,
        HASHDIFF_PARTY_BANKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_prp_pp_msp_msd_prop_pv__sat_aug_party_banking') }}
    where PARTY_HKEY__PROPOSER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        APPROVED_OR_REJECTED_BY,
        APPROVED_OR_REJECTED_DATE,
        BANK_DETAIL_REMARKS,
        BANK_VERIFIED_ACCOUNT_HOLDER_NAME,
        NEFT_VERIFICATION_STATUS,
        PENNY_DROP_NAME_MATCH_SCORE,
        PENNY_DROP_WAIVED_INDICATOR,
        REFUND_TO_BANK_GUARANTEE_HOLDER_ACCOUNT_REFERENCE,
        HASHDIFF_PARTY_BANKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_prp_pp_sp_pv__sat_aug_party_banking') }}
    where PARTY_HKEY__PROPOSER is not null
