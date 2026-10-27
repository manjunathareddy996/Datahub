{{ config(materialized='view') }}

-- UNPIVOT for SAT_POLICY_PREMIUM_HEAD from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- one row PER INSTANCE: 7 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by ADJUSTED_INDICATOR, COVERAGE_REFERENCE, PREMIUM_HEAD_CODE, SECTION.
-- The hash is taken once, downstream, by stg2_mtv2_up__uwr_pol_ins_rskp_sp_pv__sat_policy_premium_head.
--
-- Payload is null-padded to the SATELLITE's full payload (4 column(s)), not to this
-- feeder's columns, so every feeder of SAT_POLICY_PREMIUM_HEAD is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   endorsement_premium_risk_n               1 attribute(s)
--   net_premium_premium_ccy_risk_n           1 attribute(s)
--   premium_risk_n                           1 attribute(s)
--   premium_bhd_risk_n                       1 attribute(s)
--   risk_premium_base_ccy_risk_n             1 attribute(s)
--   risk_premium_txn_ccy_risk_n              1 attribute(s)
--   total_fees_risk_n                        1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'ALL'), '#ALL'),'') as COVERAGE_REFERENCE,
        'ENDORSEMENT_PREMIUM' as PREMIUM_HEAD_CODE,
        'RISK' as SECTION,
        endorsement_premium as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where endorsement_premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'ALL'), '#ALL'),'') as COVERAGE_REFERENCE,
        'NET_PREMIUM_PREMIUM_CCY' as PREMIUM_HEAD_CODE,
        'RISK' as SECTION,
        cast(null as varchar) as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        net_premium_in_premium_currency as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where net_premium_in_premium_currency is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'ALL'), '#ALL'),'') as COVERAGE_REFERENCE,
        'PREMIUM' as PREMIUM_HEAD_CODE,
        'RISK' as SECTION,
        premium as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where premium is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'ALL'), '#ALL'),'') as COVERAGE_REFERENCE,
        'PREMIUM_BHD' as PREMIUM_HEAD_CODE,
        'RISK' as SECTION,
        premium_in_bhd as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where premium_in_bhd is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'ALL'), '#ALL'),'') as COVERAGE_REFERENCE,
        'RISK_PREMIUM_BASE_CCY' as PREMIUM_HEAD_CODE,
        'RISK' as SECTION,
        risk_premium_in_base_currency as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where risk_premium_in_base_currency is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'ALL'), '#ALL'),'') as COVERAGE_REFERENCE,
        'RISK_PREMIUM_TXN_CCY' as PREMIUM_HEAD_CODE,
        'RISK' as SECTION,
        risk_premium_in_transaction_currency as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where risk_premium_in_transaction_currency is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_number),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_policy_number), ''), nullif(trim(foreign_key), '')) end),'') as POLICY_BK,
        'N' as ADJUSTED_INDICATOR,
        coalesce(nullif(trim(coalesce(nullif(trim(w1_pol_risk_id), ''), '') || '#' || 'ALL'), '#ALL'),'') as COVERAGE_REFERENCE,
        'TOTAL_FEES' as PREMIUM_HEAD_CODE,
        'RISK' as SECTION,
        total_fees as BASE_AMOUNT,
        cast(null as varchar) as LOADING_AMOUNT,
        cast(null as varchar) as NET_HEAD_PREMIUM,
        cast(null as varchar) as PREMIUM_BASIS,
        'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where total_fees is not null
