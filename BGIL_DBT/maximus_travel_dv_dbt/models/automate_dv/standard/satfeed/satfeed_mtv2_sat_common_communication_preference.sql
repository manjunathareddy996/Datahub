{{ config(materialized='view') }}

-- FEED for SAT_COMMON_COMMUNICATION_PREFERENCE (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 4 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_COMMON_COMMUNICATION_PREFERENCE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__INSURED_MEMBER as PARTY_HKEY,
        GO_GREEN_OPT_IN_INDICATOR as GO_GREEN_OPT_IN_INDICATOR,
        PREFERRED_CHANNEL_CODE as PREFERRED_CHANNEL_CODE,
        PREFERRED_LANGUAGE_CODE as PREFERRED_LANGUAGE_CODE,
        SMS_OPT_IN_INDICATOR as SMS_OPT_IN_INDICATOR,
        HASHDIFF_COMMON_COMMUNICATION_PREFERENCE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_mbr_pp_sp_pv') }}
    where PARTY_HKEY__INSURED_MEMBER is not null
union all
    select
        PARTY_HKEY__POLICYHOLDER as PARTY_HKEY,
        GO_GREEN_OPT_IN_INDICATOR as GO_GREEN_OPT_IN_INDICATOR,
        PREFERRED_CHANNEL_CODE as PREFERRED_CHANNEL_CODE,
        PREFERRED_LANGUAGE_CODE as PREFERRED_LANGUAGE_CODE,
        SMS_OPT_IN_INDICATOR as SMS_OPT_IN_INDICATOR,
        HASHDIFF_COMMON_COMMUNICATION_PREFERENCE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where PARTY_HKEY__POLICYHOLDER is not null
union all
    select
        PARTY_HKEY__PROPOSER as PARTY_HKEY,
        GO_GREEN_OPT_IN_INDICATOR as GO_GREEN_OPT_IN_INDICATOR,
        PREFERRED_CHANNEL_CODE as PREFERRED_CHANNEL_CODE,
        PREFERRED_LANGUAGE_CODE as PREFERRED_LANGUAGE_CODE,
        SMS_OPT_IN_INDICATOR as SMS_OPT_IN_INDICATOR,
        HASHDIFF_COMMON_COMMUNICATION_PREFERENCE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_HKEY__PROPOSER is not null
union all
    select
        PARTY_HKEY__POLICYHOLDER as PARTY_HKEY,
        GO_GREEN_OPT_IN_INDICATOR as GO_GREEN_OPT_IN_INDICATOR,
        PREFERRED_CHANNEL_CODE as PREFERRED_CHANNEL_CODE,
        PREFERRED_LANGUAGE_CODE as PREFERRED_LANGUAGE_CODE,
        SMS_OPT_IN_INDICATOR as SMS_OPT_IN_INDICATOR,
        HASHDIFF_COMMON_COMMUNICATION_PREFERENCE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where PARTY_HKEY__POLICYHOLDER is not null
