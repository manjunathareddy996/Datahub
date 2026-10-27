{{ config(materialized='view') }}

-- FEED for SAT_LNK_ROLE_NOMINEE_BENEFICIARY (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 3 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_LNK_ROLE_NOMINEE_BENEFICIARY to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__NOMINEE as PARTY_HKEY,
        APPOINTEE_NAME as APPOINTEE_NAME,
        NOMINATION_PERCENTAGE as NOMINATION_PERCENTAGE,
        RELATIONSHIP_TO_INSURED as RELATIONSHIP_TO_INSURED,
        HASHDIFF_LNK_ROLE_NOMINEE_BENEFICIARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }}
    where PARTY_HKEY__NOMINEE is not null
union all
    select
        PARTY_HKEY__NOMINEE as PARTY_HKEY,
        APPOINTEE_NAME as APPOINTEE_NAME,
        NOMINATION_PERCENTAGE as NOMINATION_PERCENTAGE,
        RELATIONSHIP_TO_INSURED as RELATIONSHIP_TO_INSURED,
        HASHDIFF_LNK_ROLE_NOMINEE_BENEFICIARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv') }}
    where PARTY_HKEY__NOMINEE is not null
