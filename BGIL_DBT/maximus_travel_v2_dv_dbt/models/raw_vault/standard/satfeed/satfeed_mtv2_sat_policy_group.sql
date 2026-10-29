{{ config(materialized='view') }}

-- FEED for SAT_POLICY_GROUP (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 7 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_GROUP to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        GROUP_TYPE as GROUP_TYPE,
        CHILD_POLICY_PLAN_CODE as CHILD_POLICY_PLAN_CODE,
        EMPLOYER_ORGANISATION_NAME as EMPLOYER_ORGANISATION_NAME,
        GLOBAL_ACCOUNT_INDICATOR as GLOBAL_ACCOUNT_INDICATOR,
        GROUP_NAME as GROUP_NAME,
        INSURED_EMPLOYEE_CODE as INSURED_EMPLOYEE_CODE,
        PROGRAM_IDENTIFIER as PROGRAM_IDENTIFIER,
        HASHDIFF_POLICY_GROUP as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where POLICY_HKEY is not null
