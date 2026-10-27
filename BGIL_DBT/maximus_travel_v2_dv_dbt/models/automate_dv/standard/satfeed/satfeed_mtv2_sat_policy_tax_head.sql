{{ config(materialized='view') }}

-- FEED for SAT_POLICY_TAX_HEAD (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_TAX_HEAD to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        TAX_HEAD_CODE as TAX_HEAD_CODE,
        TAX_AMOUNT as TAX_AMOUNT,
        HASHDIFF_POLICY_TAX_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        TAX_HEAD_CODE as TAX_HEAD_CODE,
        TAX_AMOUNT as TAX_AMOUNT,
        HASHDIFF_POLICY_TAX_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        TAX_HEAD_CODE as TAX_HEAD_CODE,
        TAX_AMOUNT as TAX_AMOUNT,
        HASHDIFF_POLICY_TAX_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where POLICY_HKEY is not null
