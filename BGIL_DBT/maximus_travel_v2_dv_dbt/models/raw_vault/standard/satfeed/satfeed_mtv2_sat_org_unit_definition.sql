{{ config(materialized='view') }}

-- FEED for SAT_ORG_UNIT_DEFINITION (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 2 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_ORG_UNIT_DEFINITION to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        ORG_UNIT_HKEY as ORG_UNIT_HKEY,
        COST_CENTRE_CODE as COST_CENTRE_CODE,
        ORG_UNIT_NAME as ORG_UNIT_NAME,
        HASHDIFF_ORG_UNIT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol') }}
    where ORG_UNIT_HKEY is not null
union all
    select
        ORG_UNIT_HKEY as ORG_UNIT_HKEY,
        COST_CENTRE_CODE as COST_CENTRE_CODE,
        ORG_UNIT_NAME as ORG_UNIT_NAME,
        HASHDIFF_ORG_UNIT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where ORG_UNIT_HKEY is not null
union all
    select
        ORG_UNIT_HKEY__POLICY_ISSUING_BRANCH as ORG_UNIT_HKEY,
        COST_CENTRE_CODE as COST_CENTRE_CODE,
        ORG_UNIT_NAME as ORG_UNIT_NAME,
        HASHDIFF_ORG_UNIT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd') }}
    where ORG_UNIT_HKEY__POLICY_ISSUING_BRANCH is not null
union all
    select
        ORG_UNIT_HKEY as ORG_UNIT_HKEY,
        COST_CENTRE_CODE as COST_CENTRE_CODE,
        ORG_UNIT_NAME as ORG_UNIT_NAME,
        HASHDIFF_ORG_UNIT_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where ORG_UNIT_HKEY is not null
