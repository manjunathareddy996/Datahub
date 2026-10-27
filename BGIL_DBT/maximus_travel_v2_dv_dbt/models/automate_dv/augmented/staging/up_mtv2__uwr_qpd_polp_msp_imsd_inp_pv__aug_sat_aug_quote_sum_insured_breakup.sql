{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_QUOTE_SUM_INSURED_BREAKUP from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
-- 3 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ACE' as SUM_INSURED_HEAD,
        coalesce(sum_insured_ace, sum_insuredace) as SUM_INSURED_AMOUNT,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where sum_insured_ace is not null or sum_insuredace is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ACE_MAIN_SUB_COVER' as SUM_INSURED_HEAD,
        sum_insured_ace_for_main_sub_cover as SUM_INSURED_AMOUNT,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where sum_insured_ace_for_main_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'LINE_SUM_INSURED' as SUM_INSURED_HEAD,
        sum_insured as SUM_INSURED_AMOUNT,
        'NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where sum_insured is not null
