{{ config(materialized='view') }}

-- AUGMENTED instance fan-out for SAT_AUG_QUOTE_COVERAGE_SCHEDULE from
--   NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW
-- 8 branch(es): a column-as-instance family on the unratified track.
--
-- Payload null-padded to the SATELLITE, not to a branch (BUILD_RULES 6).

    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'ACE' as COVERAGE_REFERENCE,
        ace_duration as COVERAGE_DURATION,
        cast(null as varchar) as DEDUCTIBLE_AMOUNT,
        delay_exceeding_ace as DELAY_TRIGGER_THRESHOLD,
        cast(null as varchar) as EXCLUDED_COUNTRIES,
        cast(null as varchar) as EXCLUDED_EVENTS,
        cast(null as varchar) as ITEMS_COVERED,
        ace_premium_type as PREMIUM_BASIS,
        cast(null as varchar) as SUB_COVER_SELECTION,
        cast(null as varchar) as SUM_INSURED_AMOUNT,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where ace_duration is not null or ace_premium_type is not null or delay_exceeding_ace is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'AMBULANCE' as COVERAGE_REFERENCE,
        cast(null as varchar) as COVERAGE_DURATION,
        cast(null as varchar) as DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as DELAY_TRIGGER_THRESHOLD,
        cast(null as varchar) as EXCLUDED_COUNTRIES,
        cast(null as varchar) as EXCLUDED_EVENTS,
        cast(null as varchar) as ITEMS_COVERED,
        cast(null as varchar) as PREMIUM_BASIS,
        ambulance_sub_cover as SUB_COVER_SELECTION,
        cast(null as varchar) as SUM_INSURED_AMOUNT,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where ambulance_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'BASE' as COVERAGE_REFERENCE,
        cast(null as varchar) as COVERAGE_DURATION,
        deductible_value_sublimit as DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as DELAY_TRIGGER_THRESHOLD,
        excluded_countries as EXCLUDED_COUNTRIES,
        excluded_events as EXCLUDED_EVENTS,
        items_covered as ITEMS_COVERED,
        cast(null as varchar) as PREMIUM_BASIS,
        cast(null as varchar) as SUB_COVER_SELECTION,
        limit_sum_insured as SUM_INSURED_AMOUNT,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where deductible_value_sublimit is not null or excluded_countries is not null or excluded_events is not null or items_covered is not null or limit_sum_insured is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'BENEFIT' as COVERAGE_REFERENCE,
        cast(null as varchar) as COVERAGE_DURATION,
        cast(null as varchar) as DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as DELAY_TRIGGER_THRESHOLD,
        cast(null as varchar) as EXCLUDED_COUNTRIES,
        cast(null as varchar) as EXCLUDED_EVENTS,
        cast(null as varchar) as ITEMS_COVERED,
        cast(null as varchar) as PREMIUM_BASIS,
        cast(null as varchar) as SUB_COVER_SELECTION,
        benefit_amount as SUM_INSURED_AMOUNT,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where benefit_amount is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'TRAVEL_INCONVENIENCE' as COVERAGE_REFERENCE,
        cast(null as varchar) as COVERAGE_DURATION,
        cast(null as varchar) as DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as DELAY_TRIGGER_THRESHOLD,
        cast(null as varchar) as EXCLUDED_COUNTRIES,
        cast(null as varchar) as EXCLUDED_EVENTS,
        cast(null as varchar) as ITEMS_COVERED,
        cast(null as varchar) as PREMIUM_BASIS,
        inconvenience_sub_cover as SUB_COVER_SELECTION,
        cast(null as varchar) as SUM_INSURED_AMOUNT,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where inconvenience_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'TRIP_CANCELLATION' as COVERAGE_REFERENCE,
        cast(null as varchar) as COVERAGE_DURATION,
        cast(null as varchar) as DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as DELAY_TRIGGER_THRESHOLD,
        cast(null as varchar) as EXCLUDED_COUNTRIES,
        cast(null as varchar) as EXCLUDED_EVENTS,
        cast(null as varchar) as ITEMS_COVERED,
        cast(null as varchar) as PREMIUM_BASIS,
        cancellation_sub_cover as SUB_COVER_SELECTION,
        cast(null as varchar) as SUM_INSURED_AMOUNT,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where cancellation_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'TRIP_CANCELLATION_MAIN' as COVERAGE_REFERENCE,
        cast(null as varchar) as COVERAGE_DURATION,
        cast(null as varchar) as DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as DELAY_TRIGGER_THRESHOLD,
        cast(null as varchar) as EXCLUDED_COUNTRIES,
        cast(null as varchar) as EXCLUDED_EVENTS,
        cast(null as varchar) as ITEMS_COVERED,
        cast(null as varchar) as PREMIUM_BASIS,
        cancellation_main_sub_cover as SUB_COVER_SELECTION,
        cast(null as varchar) as SUM_INSURED_AMOUNT,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where cancellation_main_sub_cover is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_policy_quote_number),'')) is not null then nullif(trim(w0_policy_quote_number), '') end),'') as QUOTE_BK,
        'TRIP_DELAY' as COVERAGE_REFERENCE,
        cast(null as varchar) as COVERAGE_DURATION,
        cast(null as varchar) as DEDUCTIBLE_AMOUNT,
        delay_exceeding as DELAY_TRIGGER_THRESHOLD,
        cast(null as varchar) as EXCLUDED_COUNTRIES,
        cast(null as varchar) as EXCLUDED_EVENTS,
        cast(null as varchar) as ITEMS_COVERED,
        cast(null as varchar) as PREMIUM_BASIS,
        cast(null as varchar) as SUB_COVER_SELECTION,
        cast(null as varchar) as SUM_INSURED_AMOUNT,
        'MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_INPUT_MULTI_SET_DETAIL_INPUT_PROPERTY_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__uwr_qpd_polp_msp_imsd_inp_pv') }}
    where delay_exceeding is not null
