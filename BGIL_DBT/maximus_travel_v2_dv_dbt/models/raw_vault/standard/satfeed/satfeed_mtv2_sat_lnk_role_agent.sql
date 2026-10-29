{{ config(materialized='view') }}

-- FEED for SAT_LNK_ROLE_AGENT (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 9 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_LNK_ROLE_AGENT to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_ROLE_HKEY__PROPOSER as PARTY_ROLE_HKEY,
        AGENT_CODE as AGENT_CODE,
        IRDAI_AGENT_LICENCE_NUMBER as IRDAI_AGENT_LICENCE_NUMBER,
        LICENCE_CATEGORY as LICENCE_CATEGORY,
        LICENCE_EXPIRY_DATE as LICENCE_EXPIRY_DATE,
        LICENCE_ISSUE_DATE as LICENCE_ISSUE_DATE,
        SPECIAL_TDS_RATE as SPECIAL_TDS_RATE,
        IRDA_LISTED_PRIMARY_PROFESSION as IRDA_LISTED_PRIMARY_PROFESSION,
        LICENCE_DETAILS_DESCRIPTION as LICENCE_DETAILS_DESCRIPTION,
        SPECIAL_TDS_RATE_APPLICABLE_INDICATOR as SPECIAL_TDS_RATE_APPLICABLE_INDICATOR,
        HASHDIFF_LNK_ROLE_AGENT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where PARTY_ROLE_HKEY__PROPOSER is not null
