{{ config(materialized='view') }}

-- FEED for SAT_CHANNEL_DEFINITION (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_CHANNEL_DEFINITION to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        DISTRIBUTION_CHANNEL_HKEY__INTERMEDIARY as DISTRIBUTION_CHANNEL_HKEY,
        CHANNEL_NAME as CHANNEL_NAME,
        CHANNEL_REMARKS as CHANNEL_REMARKS,
        CHANNEL_TYPE as CHANNEL_TYPE,
        SUB_CHANNEL_CODE as SUB_CHANNEL_CODE,
        SUB_CHANNEL_EFFECTIVE_DATE as SUB_CHANNEL_EFFECTIVE_DATE,
        HASHDIFF_CHANNEL_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where DISTRIBUTION_CHANNEL_HKEY__INTERMEDIARY is not null
union all
    select
        DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY,
        CHANNEL_NAME as CHANNEL_NAME,
        CHANNEL_REMARKS as CHANNEL_REMARKS,
        CHANNEL_TYPE as CHANNEL_TYPE,
        SUB_CHANNEL_CODE as SUB_CHANNEL_CODE,
        SUB_CHANNEL_EFFECTIVE_DATE as SUB_CHANNEL_EFFECTIVE_DATE,
        HASHDIFF_CHANNEL_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where DISTRIBUTION_CHANNEL_HKEY is not null
union all
    select
        DISTRIBUTION_CHANNEL_HKEY__V2 as DISTRIBUTION_CHANNEL_HKEY,
        CHANNEL_NAME as CHANNEL_NAME,
        CHANNEL_REMARKS as CHANNEL_REMARKS,
        CHANNEL_TYPE as CHANNEL_TYPE,
        SUB_CHANNEL_CODE as SUB_CHANNEL_CODE,
        SUB_CHANNEL_EFFECTIVE_DATE as SUB_CHANNEL_EFFECTIVE_DATE,
        HASHDIFF_CHANNEL_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where DISTRIBUTION_CHANNEL_HKEY__V2 is not null
union all
    select
        DISTRIBUTION_CHANNEL_HKEY as DISTRIBUTION_CHANNEL_HKEY,
        CHANNEL_NAME as CHANNEL_NAME,
        CHANNEL_REMARKS as CHANNEL_REMARKS,
        CHANNEL_TYPE as CHANNEL_TYPE,
        SUB_CHANNEL_CODE as SUB_CHANNEL_CODE,
        SUB_CHANNEL_EFFECTIVE_DATE as SUB_CHANNEL_EFFECTIVE_DATE,
        HASHDIFF_CHANNEL_DEFINITION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_polp_rl_pv') }}
    where DISTRIBUTION_CHANNEL_HKEY is not null
