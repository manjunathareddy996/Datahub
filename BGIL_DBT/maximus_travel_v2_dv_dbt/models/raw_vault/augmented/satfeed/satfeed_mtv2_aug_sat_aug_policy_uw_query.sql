{{ config(materialized='view') }}

-- AUGMENTED FEED for SAT_AUG_POLICY_UW_QUERY: unions 1 per-view stage model(s).
-- Payload null-padded to the SATELLITE, and the hashdiff renamed to the bare HASHDIFF the
-- sibling writes on its augmented track too -- both of its tracks use the bare name,
-- counted 12 of 12 (BD7 / BUILD_RULES 7.7).

    select
        POLICY_HKEY as POLICY_HKEY,
        QUERY_CODE,
        QUERY_DESCRIPTION,
        QUERY_REPLY_TEXT,
        QUERY_STATUS,
        QUERY_TYPE,
        RAISED_BY_ROLE,
        RAISED_BY_USER_REFERENCE,
        REPLIED_BY_ROLE,
        REPLIED_BY_USER_REFERENCE,
        REPLY_DATE_TIME,
        SERVICE_REQUEST_NUMBER,
        HASHDIFF_POLICY_UW_QUERY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2_aug__uwr_pol_polp_msp_msd_prop_pv__sat_aug_policy_uw_query') }}
    where POLICY_HKEY is not null
