{{ config(materialized='view') }}

-- FEED for SAT_PARTY_BANKING (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 7 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PARTY_BANKING to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__CLAIMANT_CUSTOMER as PARTY_HKEY,
        ACCOUNT_NUMBER_MASKED as ACCOUNT_NUMBER_MASKED,
        ACCOUNT_HOLDER_NAME as ACCOUNT_HOLDER_NAME,
        ACCOUNT_TYPE as ACCOUNT_TYPE,
        BANK_NAME as BANK_NAME,
        BRANCH_NAME as BRANCH_NAME,
        IFSC_CODE as IFSC_CODE,
        MICR_CODE as MICR_CODE,
        PRIMARY_ACCOUNT_INDICATOR as PRIMARY_ACCOUNT_INDICATOR,
        HASHDIFF_PARTY_BANKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__clm_clmd_clmap_pv') }}
    where PARTY_HKEY__CLAIMANT_CUSTOMER is not null
union all
    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        ACCOUNT_NUMBER_MASKED as ACCOUNT_NUMBER_MASKED,
        ACCOUNT_HOLDER_NAME as ACCOUNT_HOLDER_NAME,
        ACCOUNT_TYPE as ACCOUNT_TYPE,
        BANK_NAME as BANK_NAME,
        BRANCH_NAME as BRANCH_NAME,
        IFSC_CODE as IFSC_CODE,
        MICR_CODE as MICR_CODE,
        PRIMARY_ACCOUNT_INDICATOR as PRIMARY_ACCOUNT_INDICATOR,
        HASHDIFF_PARTY_BANKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_msp_msd_prop_pv') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        ACCOUNT_NUMBER_MASKED as ACCOUNT_NUMBER_MASKED,
        ACCOUNT_HOLDER_NAME as ACCOUNT_HOLDER_NAME,
        ACCOUNT_TYPE as ACCOUNT_TYPE,
        BANK_NAME as BANK_NAME,
        BRANCH_NAME as BRANCH_NAME,
        IFSC_CODE as IFSC_CODE,
        MICR_CODE as MICR_CODE,
        PRIMARY_ACCOUNT_INDICATOR as PRIMARY_ACCOUNT_INDICATOR,
        HASHDIFF_PARTY_BANKING as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_msp_msd_prop_pv') }}
    where PARTY_HKEY__PROPOSER is not null
