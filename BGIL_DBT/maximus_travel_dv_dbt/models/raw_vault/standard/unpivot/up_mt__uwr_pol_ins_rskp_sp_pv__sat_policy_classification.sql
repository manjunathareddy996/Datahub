{{ config(materialized='view') }}

-- UNPIVOT for SAT_POLICY_CLASSIFICATION from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 2 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by CLASSIFICATION_TYPE.
-- The hash is taken once, downstream, by stg2_mt_up__uwr_pol_ins_rskp_sp_pv__sat_policy_classification.
--
-- Payload is null-padded to the SATELLITE's full payload (1 column(s)), not to this
-- feeder's columns, so every feeder of SAT_POLICY_CLASSIFICATION is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   banca_policy                             1 attribute(s)
--   policy_plan                              1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'BANCA_POLICY' as CLASSIFICATION_TYPE,
        banca_policy as CLASSIFICATION_VALUE,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_rskp_sp_pv') }}
    where banca_policy is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'POLICY_PLAN' as CLASSIFICATION_TYPE,
        coalesce(policyplan, policy_plan) as CLASSIFICATION_VALUE,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_pol_ins_rskp_sp_pv') }}
    where policy_plan is not null or policyplan is not null
