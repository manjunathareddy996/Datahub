{{ config(materialized='view') }}

-- FEED for SAT_PARTY_CONTACT_ADDRESS_LINK (target track): unions 6 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PARTY_CONTACT_ADDRESS_LINK to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_LOCATION_HKEY__INSURED_MEMBER_ADDRESS as PARTY_LOCATION_HKEY,
        ADDRESS_USAGE_TYPE as ADDRESS_USAGE_TYPE,
        ADDRESS_PROOF_TYPE as ADDRESS_PROOF_TYPE,
        HASHDIFF_PARTY_CONTACT_ADDRESS_LINK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa') }}
    where PARTY_LOCATION_HKEY__INSURED_MEMBER_ADDRESS is not null
union all
    select
        PARTY_LOCATION_HKEY__INSURED_MEMBER as PARTY_LOCATION_HKEY,
        ADDRESS_USAGE_TYPE as ADDRESS_USAGE_TYPE,
        ADDRESS_PROOF_TYPE as ADDRESS_PROOF_TYPE,
        HASHDIFF_PARTY_CONTACT_ADDRESS_LINK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pa_address_prop_pv') }}
    where PARTY_LOCATION_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL as PARTY_LOCATION_HKEY,
        ADDRESS_USAGE_TYPE as ADDRESS_USAGE_TYPE,
        ADDRESS_PROOF_TYPE as ADDRESS_PROOF_TYPE,
        HASHDIFF_PARTY_CONTACT_ADDRESS_LINK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL is not null
union all
    select
        PARTY_LOCATION_HKEY__PROPOSER_ADDRESS as PARTY_LOCATION_HKEY,
        ADDRESS_USAGE_TYPE as ADDRESS_USAGE_TYPE,
        ADDRESS_PROOF_TYPE as ADDRESS_PROOF_TYPE,
        HASHDIFF_PARTY_CONTACT_ADDRESS_LINK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pa') }}
    where PARTY_LOCATION_HKEY__PROPOSER_ADDRESS is not null
union all
    select
        PARTY_LOCATION_HKEY__PROPOSER as PARTY_LOCATION_HKEY,
        ADDRESS_USAGE_TYPE as ADDRESS_USAGE_TYPE,
        ADDRESS_PROOF_TYPE as ADDRESS_PROOF_TYPE,
        HASHDIFF_PARTY_CONTACT_ADDRESS_LINK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pa_address_prop_pv') }}
    where PARTY_LOCATION_HKEY__PROPOSER is not null
union all
    select
        PARTY_LOCATION_HKEY__PROPOSER_CORRESPONDENCE_LOCAL as PARTY_LOCATION_HKEY,
        ADDRESS_USAGE_TYPE as ADDRESS_USAGE_TYPE,
        ADDRESS_PROOF_TYPE as ADDRESS_PROOF_TYPE,
        HASHDIFF_PARTY_CONTACT_ADDRESS_LINK as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_LOCATION_HKEY__PROPOSER_CORRESPONDENCE_LOCAL is not null
