{{ config(materialized='view') }}

-- FEED for SAT_COMMON_BUSINESS_AUDIT (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 3 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_COMMON_BUSINESS_AUDIT to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        CREATED_BY_USER_REFERENCE as CREATED_BY_USER_REFERENCE,
        CREATED_DATE as CREATED_DATE,
        SOURCE_APPLICATION_NAME as SOURCE_APPLICATION_NAME,
        HASHDIFF_COMMON_BUSINESS_AUDIT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        CREATED_BY_USER_REFERENCE as CREATED_BY_USER_REFERENCE,
        CREATED_DATE as CREATED_DATE,
        SOURCE_APPLICATION_NAME as SOURCE_APPLICATION_NAME,
        HASHDIFF_COMMON_BUSINESS_AUDIT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where POLICY_HKEY is not null
