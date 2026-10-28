{{ config(materialized='view') }}

-- UNPIVOT for SAT_LNK_PARTY_ROLE_CORE from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 2 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by ROLE_CODE, ROLE_SEQUENCE.
-- The hash is taken once, downstream, by stg2_mtv2_up__uwr_pol_prp_pp_sp_pv__sat_lnk_party_role_core.
--
-- Payload is null-padded to the SATELLITE's full payload (1 column(s)), not to this
-- feeder's columns, so every feeder of SAT_LNK_PARTY_ROLE_CORE is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   intermediary_1                           1 attribute(s)
--   1                                        0 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        'INTERMEDIARY' as ROLE_CODE,
        '1' as ROLE_SEQUENCE,
        intermediary_type as ROLE_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where intermediary_type is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'') as PARTY_BK__PROPOSER,
        coalesce(nullif(trim(party_function), ''),'') as ROLE_CODE,
        '1' as ROLE_SEQUENCE,
        cast(null as varchar) as ROLE_TYPE,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_prp_pp_sp_pv') }}
    where 1 = 1
