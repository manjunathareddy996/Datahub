{{ config(materialized='view') }}

-- FEED for SAT_RISK_PERSON_MEMBER (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_RISK_PERSON_MEMBER to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        MEMBER_SEQUENCE as MEMBER_SEQUENCE,
        DATE_OF_BIRTH as DATE_OF_BIRTH,
        HASHDIFF_RISK_PERSON_MEMBER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where RISK_OBJECT_HKEY is not null
union all
    select
        RISK_OBJECT_HKEY as RISK_OBJECT_HKEY,
        MEMBER_SEQUENCE as MEMBER_SEQUENCE,
        DATE_OF_BIRTH as DATE_OF_BIRTH,
        HASHDIFF_RISK_PERSON_MEMBER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where RISK_OBJECT_HKEY is not null
